import test from "node:test";
import assert from "node:assert/strict";
import { filterRecords, recordsToCsv, buildFallback, displayValue } from "../featurePack.mjs";
const rows=[{id:1,reference:"A-1",state:"intake",risk:"High",amount:0},{id:2,reference:"B-2",state:"closed",risk:"Low",amount:250}];
test("filterRecords searches/filters preserving 0 rows",()=>{ assert.equal(filterRecords(rows,{q:"a-1"}).length,1); assert.equal(filterRecords(rows,{state:"closed"})[0].reference,"B-2"); assert.equal(filterRecords(rows,{risk:"High"})[0].amount,0); });
test("recordsToCsv preserves false/0",()=>{ const csv=recordsToCsv([{name:"x,y",flag:false,n:0}]); assert.ok(csv.includes('"x,y"')); assert.ok(csv.includes("false")); assert.equal(displayValue(0),"0"); assert.equal(displayValue(""),"— (empty)"); });
test("buildFallback labelled aiGenerated:false",()=>{ const out=buildFallback({title:"CDR Reconciliation"},rows,"CDR leakage summary"); assert.equal(out.aiGenerated,false); assert.equal(out.recordCount,2); assert.ok(out.sections.length>=2); });
