typeset -A DB_TUNNELS

DB_TUNNELS=(
  mds-prd-mysql     "13306 mds-prd-up.czc7hf5iowtu.us-east-1.rds.amazonaws.com 3306 mds-prd-app3 mysql"
  cpi-uat-pgsql     "15432 cpi-fp-uat-db.cfiuscqokbxn.us-west-2.rds.amazonaws.com 5432 cpi-loadtest-02 psql"
  fmac-prd-pgsql    "25432 fmac-prd-postgres-refreshed-vpc-fixed.civgewww4kz6.us-east-1.rds.amazonaws.com 5432 fmac-prd-app1 psql"
  fmac-dev-pgsql    "35432 fmac-dev-database.cnme8k02ysjk.us-west-2.rds.amazonaws.com 5432 fmac-dev-app1 psql"
  mft-prd-pgsql     "45432 mft-db1.caveo4o6dgms.us-east-1.rds.amazonaws.com 5432 fmac-dev-app1 psql"
  asa-prd-pgsql     "55432 rds-use1-prd-asa-totara-primary-enc.c0u6atpzuk44.us-east-1.rds.amazonaws.com 5432 asa-prd-cron psql"
  asa-tst-pgsql     "54325 rds-use2-tst-asa-totara-primary.cxnsznbo9mn3.us-east-2.rds.amazonaws.com 5432 asa-tst-app3 psql"
  mct-prd-pgsql     "65432 mct-prd-db2.ctmu5wphhpzk.us-east-1.rds.amazonaws.com 5432 mct-prd-lift-app1 psql"
  cpi-prd-pgsql     "15433 cpi-prd-database1.cbskawk2au2q.us-east-1.rds.amazonaws.com 5432 cpi-prd-cron psql"
)
