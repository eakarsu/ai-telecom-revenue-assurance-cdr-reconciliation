CREATE TABLE IF NOT EXISTS app_users(
  id BIGSERIAL PRIMARY KEY,email TEXT UNIQUE NOT NULL,name TEXT NOT NULL,role TEXT NOT NULL,password_hash TEXT NOT NULL,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS workflow_cases(
  id BIGSERIAL PRIMARY KEY,workflow_id TEXT NOT NULL,reference TEXT UNIQUE NOT NULL,subject TEXT NOT NULL,owner TEXT NOT NULL,state TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,payload JSONB NOT NULL DEFAULT '{}'::jsonb,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS audit_events(
  id BIGSERIAL PRIMARY KEY,event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),actor TEXT NOT NULL,action TEXT NOT NULL,object_type TEXT NOT NULL,object_reference TEXT NOT NULL,detail TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS saved_analyses(
  id BIGSERIAL PRIMARY KEY,workflow_id TEXT NOT NULL,actor TEXT NOT NULL,analysis_type TEXT NOT NULL,inputs JSONB NOT NULL,result JSONB NOT NULL,provider TEXT NOT NULL,model TEXT,created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS integration_state(
  id TEXT PRIMARY KEY,name TEXT NOT NULL,category TEXT NOT NULL,mode TEXT NOT NULL,status TEXT NOT NULL,last_tested TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_workflow_cases_workflow ON workflow_cases(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_cases_due ON workflow_cases(due_date);
CREATE INDEX IF NOT EXISTS idx_audit_events_time ON audit_events(event_time DESC);

CREATE TABLE IF NOT EXISTS "op_cdr"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_networkElement" TEXT NOT NULL,
  "data_period" TEXT NOT NULL,
  "data_sourceEvents" NUMERIC(16,2) NOT NULL,
  "data_billedEvents" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_cdr_due ON "op_cdr"(due_date);

CREATE TABLE IF NOT EXISTS "op_rating"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_product" TEXT NOT NULL,
  "data_subscriberSegment" TEXT NOT NULL,
  "data_expectedCharge" NUMERIC(16,2) NOT NULL,
  "data_actualCharge" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_rating_due ON "op_rating"(due_date);

CREATE TABLE IF NOT EXISTS "op_roaming"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_partner" TEXT NOT NULL,
  "data_settlementPeriod" TEXT NOT NULL,
  "data_partnerInvoice" NUMERIC(16,2) NOT NULL,
  "data_calculatedAmount" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_roaming_due ON "op_roaming"(due_date);

CREATE TABLE IF NOT EXISTS "op_interconnect"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_carrier" TEXT NOT NULL,
  "data_route" TEXT NOT NULL,
  "data_minutes" NUMERIC(16,2) NOT NULL,
  "data_settlementVariance" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_interconnect_due ON "op_interconnect"(due_date);

CREATE TABLE IF NOT EXISTS "op_order_bill"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_serviceOrder" TEXT NOT NULL,
  "data_activationDate" DATE NOT NULL,
  "data_billingStatus" TEXT NOT NULL,
  "data_monthlyCharge" NUMERIC(16,2) NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_order_bill_due ON "op_order_bill"(due_date);

CREATE TABLE IF NOT EXISTS "op_discount"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_account" TEXT NOT NULL,
  "data_discount" TEXT NOT NULL,
  "data_discountValue" NUMERIC(16,2) NOT NULL,
  "data_issue" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_discount_due ON "op_discount"(due_date);

CREATE TABLE IF NOT EXISTS "op_collections"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_account" TEXT NOT NULL,
  "data_revenueType" TEXT NOT NULL,
  "data_amount" NUMERIC(16,2) NOT NULL,
  "data_agingBucket" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_collections_due ON "op_collections"(due_date);

CREATE TABLE IF NOT EXISTS "op_leakage"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_caseId" TEXT NOT NULL,
  "data_leakageType" TEXT NOT NULL,
  "data_estimatedValue" NUMERIC(16,2) NOT NULL,
  "data_rootCause" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_leakage_due ON "op_leakage"(due_date);

CREATE TABLE IF NOT EXISTS "op_product_catalog"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_product" TEXT NOT NULL,
  "data_tariff" TEXT NOT NULL,
  "data_monthlyCharge" NUMERIC(16,2) NOT NULL,
  "data_effectiveDate" DATE NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_product_catalog_due ON "op_product_catalog"(due_date);

CREATE TABLE IF NOT EXISTS "op_network_elements"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_element" TEXT NOT NULL,
  "data_elementType" TEXT NOT NULL,
  "data_region" TEXT NOT NULL,
  "data_mediationFeed" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_network_elements_due ON "op_network_elements"(due_date);

CREATE TABLE IF NOT EXISTS "op_partner_registry"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_partner" TEXT NOT NULL,
  "data_agreement" TEXT NOT NULL,
  "data_currency" TEXT NOT NULL,
  "data_settlementCycle" TEXT NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_partner_registry_due ON "op_partner_registry"(due_date);

CREATE TABLE IF NOT EXISTS "op_rating_rules"(
  id BIGSERIAL PRIMARY KEY,reference TEXT UNIQUE NOT NULL,status TEXT NOT NULL,owner TEXT NOT NULL,risk TEXT NOT NULL,due_date DATE NOT NULL,amount NUMERIC(16,2) NOT NULL DEFAULT 0,
  "data_ruleId" TEXT NOT NULL,
  "data_eventType" TEXT NOT NULL,
  "data_unitRate" NUMERIC(16,2) NOT NULL,
  "data_effectiveDate" DATE NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_op_rating_rules_due ON "op_rating_rules"(due_date);
