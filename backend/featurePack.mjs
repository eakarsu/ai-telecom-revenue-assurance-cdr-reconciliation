// Feature pack: search/filter helpers, CSV export, deterministic AI fallback (offline, aiGenerated:false).
export function displayValue(v){ if(v===false) return "false"; if(v===0) return "0"; if(v===""||v==null) return "— (empty)"; return String(v); }
export function filterRecords(items,{q="",status="",state="",risk=""}={}){
  const needle=String(q||"").trim().toLowerCase();
  return (items||[]).filter(item=>{
    if(status && String(item.status||"")!==status) return false;
    if(state && String(item.state||"")!==state) return false;
    if(risk && String(item.risk||"")!==risk) return false;
    if(!needle) return true;
    return JSON.stringify(item).toLowerCase().includes(needle);
  });
}
function csvCell(v){ if(v==null) return ""; const t=typeof v==="object"?JSON.stringify(v):String(v); return /[",\n]/.test(t)?`"${t.replace(/"/g,'""')}"`:t; }
export function recordsToCsv(items){ const rows=items||[]; const cols=[...new Set(rows.flatMap(r=>Object.keys(r||{})))]; if(!cols.length) return ""; return [cols.join(","),...rows.map(r=>cols.map(c=>csvCell(r[c])).join(","))].join("\n")+"\n"; }
export const CDR_INSIGHTS=["CDR leakage summary","Rating variance summary","Settlement readiness checklist"];
export function buildFallback(workflow, items, insight){
  const rows=items||[]; const chosen=CDR_INSIGHTS.includes(insight)?insight:CDR_INSIGHTS[0];
  const total=rows.reduce((s,r)=>s+(Number(r.amount)||0),0);
  const high=rows.filter(r=>["High","Critical"].includes(r.risk)).length;
  const open=rows.filter(r=>!["approved","closed"].includes(String(r.state||"").toLowerCase())).length;
  let detail;
  if(chosen===CDR_INSIGHTS[1]) detail=`Deterministic rating view over ${rows.length} own workflow case(s): represented value ${total}, ${high} high/critical risk. Compare expected vs actual charges in the saved payloads before adjusting invoices.`;
  else if(chosen===CDR_INSIGHTS[2]) detail=`Settlement readiness over ${rows.length} own case(s): ${open} not yet approved/closed. Confirm mediation, rating, and invoice evidence is retained for each open case.`;
  else detail=`Deterministic CDR leakage view over ${rows.length} own case(s) for ${workflow?workflow.title:"all workflows"}: represented value ${total}, ${high} high/critical risk, ${open} open. Zero and empty values are preserved.`;
  return { aiGenerated:false, provider:"deterministic-fallback", model:"local-rules", insight:chosen,
    headline:`${chosen} — deterministic fallback (not AI-generated)`,
    metrics:[{label:"Cases reviewed",value:displayValue(rows.length)},{label:"Open cases",value:displayValue(open)},{label:"High / critical risk",value:displayValue(high)},{label:"Represented value",value:displayValue(total)}],
    sections:[{title:chosen,detail},{title:"How this was produced",detail:"Local deterministic rules over this workspace's own saved workflow cases. No provider was called."},{title:"Review required",detail:"Validate CDR, mediation, and rating evidence before billing or settlement action."}],
    actions:["Validate flagged cases against source CDRs","Assign owners for open high-risk cases","Retain this fallback output with the audit history"],
    disclaimer:"Deterministic fallback over own records only; not a billing determination.", recordCount:rows.length };
}
export function mountFeaturePack(app,{pool,config}){
  app.get("/api/records/export", async (req,res)=>{
    const format=String(req.query.format||"json").toLowerCase();
    if(!["csv","json"].includes(format)) return res.status(422).json({error:"Choose CSV or JSON"});
    const rows=(await pool.query("SELECT * FROM workflow_cases ORDER BY due_date,id")).rows;
    const filtered=filterRecords(rows,{q:req.query.q,state:req.query.state,risk:req.query.risk});
    res.setHeader("Content-Disposition",`attachment; filename="workflow-cases.${format}"`);
    if(format==="csv") return res.type("text/csv").send(recordsToCsv(filtered));
    return res.json({items:filtered});
  });
  app.get("/api/ai/fallback",(_req,res)=>res.json({insights:CDR_INSIGHTS,aiGenerated:false}));
  app.post("/api/ai/fallback", async (req,res)=>{
    const workflow=config.workflows.find(w=>w.id===req.body?.workflowId)||null;
    const rows=workflow?(await pool.query("SELECT * FROM workflow_cases WHERE workflow_id=$1 ORDER BY due_date,id",[workflow.id])).rows:(await pool.query("SELECT * FROM workflow_cases ORDER BY due_date,id")).rows;
    res.json({result:buildFallback(workflow,rows,String(req.body?.insight||""))});
  });
}
