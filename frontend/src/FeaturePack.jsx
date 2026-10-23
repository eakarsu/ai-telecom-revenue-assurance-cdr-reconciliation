import React, { useEffect, useState } from 'react';
export function showValue(v){ if(v===false) return 'false'; if(v===0) return '0'; if(v===''||v==null) return '— (empty)'; return String(v); }
export async function downloadExport(format, query=''){
  const token=localStorage.getItem('portfolio_token');
  const r=await fetch(`/api/records/export?format=${format}${query}`,{headers:token?{Authorization:`Bearer ${token}`}:{}});
  if(!r.ok) throw new Error(`Export failed (${r.status})`);
  const blob=await r.blob(); const url=URL.createObjectURL(blob); const a=document.createElement('a'); a.href=url; a.download=`workflow-cases.${format}`; a.click(); setTimeout(()=>URL.revokeObjectURL(url),1000);
}
export function AiFallbackPanel({ request, workflowId }){
  const [insights,setInsights]=useState([]); const [result,setResult]=useState(null); const [error,setError]=useState(''); const [busy,setBusy]=useState('');
  useEffect(()=>{ request('/api/ai/fallback').then(d=>setInsights(d.insights||[])).catch(()=>{}); },[]);
  async function run(insight){ setBusy(insight); setError(''); try{ const d=await request('/api/ai/fallback',{method:'POST',body:JSON.stringify({workflowId,insight})}); setResult(d.result);}catch(e){setError(e.message);}finally{setBusy('');} }
  return <section className="panel"><h3>Deterministic AI fallback (offline)</h3><p className="muted">Local rules over own saved cases. Labelled aiGenerated: false — no provider is called.</p><div className="buttonRow">{insights.map(i=><button type="button" className="secondary" key={i} disabled={!!busy} onClick={()=>run(i)}>{busy===i?'Running…':i}</button>)}</div>{error&&<div className="error">{error}</div>}{result&&<div><h4>{result.headline}</h4><p className="muted">Provider: {result.provider} · aiGenerated: {showValue(result.aiGenerated)} · Records: {showValue(result.recordCount)}</p><div className="metrics">{result.metrics.map(m=><div className="metric" key={m.label}><span>{m.label}</span><strong>{showValue(m.value)}</strong></div>)}</div>{result.sections.map(s=><div key={s.title}><strong>{s.title}</strong><p>{s.detail}</p></div>)}<h4>Recommended actions</h4><ol>{result.actions.map(a=><li key={a}>{a}</li>)}</ol><small className="muted">{result.disclaimer}</small></div>}</section>;
}
export function TasksPanel({ request, notify }){
  const [tasks,setTasks]=useState([]); const [title,setTitle]=useState(''); const [error,setError]=useState('');
  async function load(){ setTasks((await request('/api/tasks')).tasks||[]); }
  useEffect(()=>{ load().catch(e=>setError(e.message)); },[]);
  async function create(e){ e.preventDefault(); try{ await request('/api/tasks',{method:'POST',body:JSON.stringify({title})}); setTitle(''); notify?.('Task created'); await load(); }catch(err){ setError(err.message);} }
  async function update(t,status){ try{ await request(`/api/tasks/${t.id}`,{method:'PATCH',body:JSON.stringify({status})}); await load(); }catch(err){ setError(err.message);} }
  return <><div className="pageTitle"><h2>Staff tasks</h2><p>Authenticated task list. Create and update durable follow-ups.</p></div>{error&&<div className="error">{error}</div>}<form className="panel" onSubmit={create}><label>New task title<input className="input" value={title} onChange={e=>setTitle(e.target.value)} required/></label><button className="primary" type="submit">Create task</button></form><section className="panel"><h3>Tasks ({tasks.length})</h3>{tasks.length?<div className="tableWrap"><table><thead><tr><th>Title</th><th>Status</th><th>Priority</th><th>Due</th><th>Actions</th></tr></thead><tbody>{tasks.map(t=><tr key={t.id}><td>{showValue(t.title)}</td><td>{showValue(t.status)}</td><td>{showValue(t.priority)}</td><td>{t.due_at?String(t.due_at).slice(0,10):'— (empty)'}</td><td><button type="button" className="secondary" onClick={()=>update(t,'DONE')}>Done</button> <button type="button" className="secondary" onClick={()=>update(t,'OPEN')}>Reopen</button> <button type="button" className="secondary" onClick={()=>update(t,'CANCELLED')}>Cancel</button></td></tr>)}</tbody></table></div>:<p className="muted">No tasks yet.</p>}</section></>;
}
