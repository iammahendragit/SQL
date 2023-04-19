use assignment;
DROP TABLE warehouse;
create table warehouse
(
ID varchar(10),
OnHandQuantity int,
OnHandQuantityDelta int,
event_type varchar(10),
event_datetime timestamp
);

insert into warehouse values
('SH0013', 278, 99 , 'OutBound', '2020-05-25 0:25'),
('SH0012', 377, 31 , 'InBound', '2020-05-24 22:00'),
('SH0011', 346, 1 , 'OutBound', '2020-05-24 15:01'),
('SH0010', 346, 1 , 'OutBound', '2020-05-23 5:00'),
('SH009', 348, 102, 'InBound', '2020-04-25 18:00'),
('SH008', 246, 43 , 'InBound', '2020-04-25 2:00'),
('SH007', 203, 2 , 'OutBound', '2020-02-25 9:00'),
('SH006', 205, 129, 'OutBound', '2020-02-18 7:00'),
('SH005', 334, 1 , 'OutBound', '2020-02-18 8:00'),
('SH004', 335, 27 , 'OutBound', '2020-01-29 5:00'),
('SH003', 362, 120, 'InBound', '2019-12-31 2:00'),
('SH002', 242, 8 , 'OutBound', '2019-05-22 0:50'),
('SH001', 250, 250, 'InBound', '2019-05-20 0:45');



with wh  as(
select * from warehouse order by event_datetime Desc),
days as (
select onhandquantity,event_datetime,
(event_datetime-interval 90 Day) as day90
,(event_datetime-interval 180 day ) as day180
,(event_datetime-interval 270 day) as day270
,(event_datetime-interval 365 day) as day365

 from wh limit 1),
 inv_90_day as(
 select sum(onhandquantitydelta) as dayold_90
 from wh cross join days
 where event_type="inbound" and wh.event_datetime>=days.day90),
 days90final as (
 select case when dayold_90>days.onhandquantity then onhandquantity else dayold_90 end dayold_90
 from inv_90_day cross join days
 ), inv_180_day as(
 select sum(onhandquantitydelta) as dayold_180
 from wh cross join days
 where event_type="inbound" and wh.event_datetime between  days.day180 and days.day90),
 days180final as (
 select case when dayold_180>(days.onhandquantity-dayold_90) then (onhandquantity-dayold_90) else dayold_180 end dayold_180
 from inv_180_day cross join days cross join days90final final
 )
, inv_270_day as(
 select sum(onhandquantitydelta) as dayold_270
 from wh cross join days
 where event_type="inbound" and wh.event_datetime between  days.day270 and days.day180),
 days270final as (
 select case when dayold_270>(days.onhandquantity-dayold_180) then (onhandquantity-dayold_180) else dayold_270 end dayold_270
 from inv_270_day cross join days cross join days180final final
 )
, inv_365_day as(
 select sum(onhandquantitydelta) as dayold_365
 from wh cross join days
 where event_type="inbound" and wh.event_datetime between  days.day365 and days.day270),
 days365final as (
 select case when dayold_365>(days.onhandquantity-(dayold_270)) then (onhandquantity-dayold_270) else dayold_365 end dayold_365
 from inv_365_day cross join days cross join days270final final
 )

select dayold_90 as "0-90  days old",dayold_180 as "90-180 days old ",dayold_270 as "180-270 days old ",dayold_365 as "270-365 days old "from days90final  cross join days180final
cross join days270final cross join days365final;