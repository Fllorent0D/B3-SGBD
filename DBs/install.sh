clear
echo SYS
sqlplus sys/oracle as sysdba << EOF
set echo on 
set heading off
@SYS/ScriptSys.sql
EXIT;
EOF
echo CB partie 1
sqlplus CB/CB@localhost:1521/orcl << EOF
set echo on 
set heading off
@CB/ScriptCB1.sql
EOF

echo CC partie 1
sqlplus CC/CC@localhost:1521/orcl << EOF
set echo on 
set heading off
@CC/ScriptCC1.sql
EOF

echo CB partie 2
sqlplus CB/CB@localhost:1521/orcl << EOF
set echo on
set heading off
@CB/ScriptCB2.sql
EOF