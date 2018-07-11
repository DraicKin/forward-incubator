--1.
select t.f_sum, t.dt_event from fw_contracts f
  join TRANS_EXTERNAL t
    on t.id_contract = f.id_contract_inst
    and t.v_status >= 'A'
    and t.dt_event= (select max(t.dt_event)
      from fw_contracts f
      join TRANS_EXTERNAL t
        on t.id_contract = f.id_contract_inst
        and t.v_status >= 'A'
    
     where f.dt_start <= current_timestamp
       and f.dt_stop > current_timestamp
       and f.v_ext_ident = '0102100000088207_MG1')
   
 where f.dt_start <= current_timestamp
   and f.dt_stop > current_timestamp
   and f.v_ext_ident = '0102100000088207_MG1';
   
--2.
select f.v_ext_ident, f.dt_reg_event, d.V_NAME from fw_contracts f
left join fw_departments d
on d.id_department=f.id_department
and d.b_deleted=0
where f.dt_start<=current_timestamp
and f.dt_stop>current_timestamp;

--3.
select V_NAME from (select count(*) as Quant_Contr, V_NAME   from fw_contracts c
    join fw_departments d
    on d.id_department=c.id_department
    where c.dt_start<=current_timestamp
    and c.dt_stop>current_timestamp
    group by d.V_NAME)
where Quant_contr<2;


--4.
select d.V_NAME, All_sum, Q_Sum, Q_contr from
(select d.id_department as ID_D, nvl2(sum(t.f_sum), sum(t.f_sum), 0) as All_sum, count(t.f_sum) as Q_sum, count(c.id_contract_inst) as Q_Contr from fw_departments d
left join fw_contracts c
on c.id_department=d.id_department
and c.dt_start <= current_timestamp
   and c.dt_stop > current_timestamp
left join trans_external t
on t.id_contract = c.id_contract_inst
    and t.v_status = 'A'
and t.dt_event> (select max(t.dt_event)
from trans_external t) - interval '1' month
where b_deleted=0
group by d.id_department) X
join fw_departments d
on d.id_department=X.ID_D

--5.
select f.v_ext_ident, f.v_status, (select count(1)
               from TRANS_EXTERNAL t
              where t.id_contract = f.id_contract_inst 
                and t.DT_EVENT<to_date('01.01.2018', 'dd.mm.yyyy')
                and t.DT_EVENT>=to_date('01.01.2017', 'dd.mm.yyyy')
                and t.v_status = 'A') as Quant

  from fw_contracts f
 where f.dt_start <= current_timestamp
   and f.dt_stop > current_timestamp
   and 3 <= (select count(1)
               from TRANS_EXTERNAL t
              where t.id_contract = f.id_contract_inst 
                and t.DT_EVENT<to_date('01.01.2018', 'dd.mm.yyyy')
                and t.DT_EVENT>=to_date('01.01.2017', 'dd.mm.yyyy')
                and t.v_status = 'A') ;
				
--6.
select distinct c.V_EXT_IDENT, c.V_STATUS, d.V_NAME
from fw_contracts c
join trans_external t
on t.id_contract = c.id_contract_inst
and t.v_status>='A'
and exists (select * from trans_external
    where t.dt_event<to_date('01.01.2018', 'dd.mm.yyyy')
    and t.dt_event>=to_date('01.01.2017', 'dd.mm.yyyy'))
left join fw_departments d
on d.id_department = c.id_department
   and d.b_deleted = 0

where c.dt_start <= current_timestamp
   and c.dt_stop > current_timestamp;
   
--7.
select distinct d.V_NAME
  from (select * from fw_contracts c
  where c.dt_start <= current_timestamp
   and c.dt_stop > current_timestamp) z
  right join fw_departments d
  on d.id_department=z.id_department
  
  and b_deleted =0
  where z.id_department is null;
  
--8. 

select distinct Quant,  Last_trans, c.v_ext_ident, u.v_username from 
(select c.id_contract_inst as ID_contr, count(id_contract) as Quant, max(t.dt_event) as Last_trans, max(t.id_source) as SOURC  
  from fw_contracts c
  left join TRANS_EXTERNAL t
    on t.id_contract = c.id_contract_inst
    and t.v_status >= 'A'
    
 where c.dt_start <= current_timestamp
   and c.dt_stop > current_timestamp
   group by c.id_contract_inst) X
   join fw_contracts c
   on c.id_contract_inst=X.ID_contr
   left join ci_users u
  on u.id_user=X.SOURC
  and u.v_status='a'
   ;
  


--9.
select f.V_Ext_ident
  from fw_contracts f
  join TRANS_EXTERNAL t
    on t.id_contract = f.id_contract_inst
    and t.id_trans=6397542
   where f.dt_start <= to_date('01.01.2016','dd.mm.yyyy')
   and f.dt_stop >= to_date('01.01.2016','dd.mm.yyyy');
   
--10.
select c.ID_CONTRACT_INST, c.V_EXT_IDENT, c.V_STATUS, cur.V_NAME   from fw_contracts c
join FW_CURRENCY cur
on cur.id_currency=c.ID_CURRENCY
and cur.b_deleted=0

where c.ID_CONTRACT_INST in (select ID_CONTRACT_INST from (select ID_CONTRACT_INST,count(distinct ID_CURRENCY) as Qu from fw_contracts c
            group by ID_CONTRACT_INST)
 where Qu>1)
and c.dt_start <= current_timestamp
   and c.dt_stop > current_timestamp;
   
--11.
select ID_CONTRACT_INST from (select ID_CONTRACT_INST, count(*) as Qu from (select * from fw_contracts c
where c.V_STATUS='C')

group by ID_CONTRACT_INST)
where Qu>1
