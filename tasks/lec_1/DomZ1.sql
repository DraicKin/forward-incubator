--1.
select count(*) as Fall from fw_process_log 
where N_STATUS = 500 
and instr( V_MESSAGE, 'Заказ 2520123')<>0;

--2.
select '2520123' as OrderNum, to_char(max(DT_TIMESTAMP),'dd.mon.yyyy') as OrderDate from fw_process_log 
where N_STATUS = 500 
and instr( V_MESSAGE, 'Заказ 2520123')<>0;

--3.
select distinct(ltrim(V_MESSAGE,'Загрузка порции заказов начиная с ')) as ORDER_NUM from fw_process_log 
where N_ACTION=12 
and V_MESSAGE<>'Загрузка порции заказов начиная с -1';

--4.
select COUNT(distinct(ltrim(V_MESSAGE,'Загрузка порции заказов начиная с '))) from fw_process_log 
where N_ACTION=12;

--5.
select sum(cast (substr(V_MESSAGE, (length(V_MESSAGE)-8)) as numeric)) as DURATIO from fw_process_log  
where N_ACTION=11;

--6.
select count(*) as CLOSED from fw_process_log 
where N_ACTION = 11 
and DT_TIMESTAMP >=TO_DATE('1, 3, 2018', 'dd.mm.yyyy') 
and DT_TIMESTAMP <=TO_DATE('31, 3, 2018', 'dd.mm.yyyy');

--7.
select count(*) as REPEA from (select SID, count(ID_LOG) as Qu from fw_process_log 
group by SID) X 
where Qu>1;

--8.
select DT_TIMESTAMP, substr(V_MESSAGE,13,instr(V_MESSAGE, '@')-13) as LOGIN from fw_process_log 
where ID_USER=11136 
and DT_TIMESTAMP=(select max(DT_TIMESTAMP) from fw_process_log 
where ID_USER=11136);

--9.
select to_char(trunc(DT_TIMESTAMP, 'MM'), 'Month') as Mont, count(*) as Quantity  from fw_process_log 
group by trunc(DT_TIMESTAMP, 'MM') ;

--10.
select count(*) as Quer, count(distinct(V_MESSAGE)) as Uniq from fw_process_log 
where N_STATUS=500 
and ID_PROCESS=5 
and DT_TIMESTAMP > to_date('22.02.2018', 'dd.mm.yyyy') 
and DT_TIMESTAMP < to_date('02.03.2018', 'dd.mm.yyyy');

--11.
select min(N_SUM) from fw_transfers 
where DT_INCOMING <= to_date('14.02.2017 12:00:00', 'dd.mm.yyyy hh24:mi:ss') 
and DT_INCOMING >= to_date('14.02.2017 10:00:00', 'dd.mm.yyyy hh24:mi:ss') 
and ID_CONTRACT_FROM <> ID_CONTRACT_TO;

--12.
select ID_CONTRACT_TO, DT_REAL, length(V_DESCRIPTION) as V_LEN from fw_transfers 
where length(V_DESCRIPTION)>22 
order by V_LEN desc;

--13.
select to_char(DT_INCOMING, 'dd.mm.yyyy') as CH_DATE, count(*) as CONTRACTS from (select * from fw_transfers 
where ID_CONTRACT_FROM=ID_CONTRACT_TO) X 
group by to_char(DT_INCOMING, 'dd.mm.yyyy');

