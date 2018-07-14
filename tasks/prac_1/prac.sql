--4.
select  Serv_Tab.v_name, dep_name, sum(ap) from (select * from fw_services sc
join fw_service se
on se.id_service=sc.id_service
and se.b_deleted=0
where sc.v_status='A'
    and sc.dt_start <= current_timestamp
    and sc.dt_stop > current_timestamp
    and sc.b_deleted=0) Serv_Tab
join (select ID_C, AP, Y.DEP, DEP_NAME
  from (select f.id_contract_inst as ID_C,
               sum(s.N_cost_period) as AP,
               d.id_department as DEP
               
          from fw_contracts f
          join fw_services_cost s
            on s.id_contract_inst = f.id_contract_inst
           and s.dt_start <= current_timestamp
           and s.dt_stop > current_timestamp
          left join fw_departments d
            on d.id_department = f.id_department
           and b_deleted = 0
           
         
         where f.dt_start <= current_timestamp
           and f.dt_stop > current_timestamp
         group by f.id_contract_inst, d.id_department) AV
			Join (select X.DEP as DEP, X.DEP_NAME as DEP_NAME, avg(X.SUMM) AS AVG_SUMM
                  from (select f.id_contract_inst as ID_C,
                               sum(s.N_cost_period) as SUMM,
                               d.id_department as DEP,
							   d.V_NAME as DEP_NAME
                          from fw_contracts f
                          join fw_services_cost s
                            on s.id_contract_inst = f.id_contract_inst
                           and s.dt_start <= current_timestamp
                           and s.dt_stop > current_timestamp
                          left join fw_departments d
                            on d.id_department = f.id_department
                           and b_deleted = 0
                          
                         where f.dt_start <= current_timestamp
                           and f.dt_stop > current_timestamp
                         group by f.id_contract_inst, d.id_department, d.V_NAME) X
						 group by X.DEP, X.DEP_NAME) Y
			on Y.Dep=Av.dep
                  where av.ap>y.avg_summ) Z3
    on Z3.ID_C=Serv_Tab.id_contract_inst
    
    group by Serv_Tab.v_name, Dep_name;

--5.	
select * from (select count(distinct fsc.n_discount_period) as CHANGES, fc.v_ext_ident as ID_C  from fw_contracts fc
join fw_services_cost fsc
on fsc.id_contract_inst=fc.id_contract_inst
and fsc.dt_start>to_date('31.10.2017', 'dd.mm.yyyy')
and fsc.dt_start<to_date('01.12.2017', 'dd.mm.yyyy')


where fc.dt_stop>current_timestamp
and fc.dt_start<fsc.dt_start

group by fc.v_ext_ident, fsc.id_service_inst) X
where X.CHANGES>=2;

--6.
select Y.DEP, Y.TP, Y.AP from (select tp.v_name as TP, d.v_name as DEP, sum(s.n_cost_period) as AP
from fw_contracts f
    join fw_services_cost s
    on s.id_contract_inst = f.id_contract_inst
    and s.dt_start <= current_timestamp
    and s.dt_stop > current_timestamp
    
    left join fw_departments d
    on d.id_department = f.id_department
    and b_deleted = 0
    
    join fw_services cs
    on cs.id_service_inst=s.id_service_inst
    and cs.b_deleted=0
    and cs.dt_start <= current_timestamp
    and cs.dt_stop > current_timestamp
    and cs.v_status='A'
    
    join fw_service fws
    on fws.id_service=cs.id_service
    and fws.b_deleted=0
    and fws.b_add_service=1
    
    join fw_tariff_plan tp
    on tp.id_tariff_plan=cs.id_tariff_plan
    and tp.dt_start <= current_timestamp
    and tp.dt_stop > current_timestamp
    and tp.b_deleted=0
    
    
    where f.dt_start <= current_timestamp
    and f.dt_stop > current_timestamp
    and f.v_status='A'
    
group by tp.v_name, d.v_name) Y

cross join 

(select X.DEP, max(X.AP) as M_AP from (select tp.v_name as TP, d.v_name as DEP, sum(s.n_cost_period) as AP
from fw_contracts f
    join fw_services_cost s
    on s.id_contract_inst = f.id_contract_inst
    and s.dt_start <= current_timestamp
    and s.dt_stop > current_timestamp
    
    left join fw_departments d
    on d.id_department = f.id_department
    and b_deleted = 0
    
    join fw_services cs
    on cs.id_service_inst=s.id_service_inst
    and cs.b_deleted=0
    and cs.dt_start <= current_timestamp
    and cs.dt_stop > current_timestamp
    and cs.v_status='A'
    
    join fw_service fws
    on fws.id_service=cs.id_service
    and fws.b_deleted=0
    and fws.b_add_service=1
    
    join fw_tariff_plan tp
    on tp.id_tariff_plan=cs.id_tariff_plan
    and tp.dt_start <= current_timestamp
    and tp.dt_stop > current_timestamp
    and tp.b_deleted=0
    
    
    where f.dt_start <= current_timestamp
    and f.dt_stop > current_timestamp
    and f.v_status='A'
    
group by tp.v_name, d.v_name) X
group by X.DEP) Z

where Z.DEP=Y.DEP
and Y.AP=Z.M_AP



