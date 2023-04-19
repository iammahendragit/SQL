use assignment;
drop table hackers;
drop table submissions;

create table hackers (hacker_id int, name varchar(40));
create table submissions (submission_date date, submission_id int, hacker_id int, score int);


insert into hackers values (15758, 'Rose');
insert into hackers values (20703, 'Angela');
insert into hackers values (36396, 'Frank');
insert into hackers values (38289, 'Patrick');
insert into hackers values (44065, 'Lisa');
insert into hackers values (53473, 'Kimberly');
insert into hackers values (62529, 'Bonnie');
insert into hackers values (79722, 'Michael');


insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 8494,    20703,	 0	);
insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 22403, 	53473,	 15	);
insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 23965, 	79722,	 60	);
insert into submissions values (date_format('2016-03-01', '%y-%m-%d'), 30173, 	36396,	 70	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 34928, 	20703,	 0	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 38740, 	15758,	 60	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 42769, 	79722,	 25	);
insert into submissions values (date_format('2016-03-02', '%y-%m-%d'), 44364, 	79722,	 60	);
insert into submissions values (date_format('2016-03-03', '%y-%m-%d'), 45440, 	20703,	 0	);
insert into submissions values (date_format('2016-03-03', '%y-%m-%d'), 49050, 	36396,	 70	);
insert into submissions values (date_format('2016-03-03', '%y-%m-%d'), 50273, 	79722,	 5	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 50344, 	20703,	 0	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 51360, 	44065,	 90	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 54404, 	53473,	 65	);
insert into submissions values (date_format('2016-03-04', '%y-%m-%d'), 61533, 	79722,	 45	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 72852, 	20703,	 0	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 74546, 	38289,	 0	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 76487, 	62529,	 0	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 82439, 	36396,	 10	);
insert into submissions values (date_format('2016-03-05', '%y-%m-%d'), 90006, 	36396,	 40	);
insert into submissions values (date_format('2016-03-06', '%y-%m-%d'), 90404, 	20703,	 0	);



select * from hackers;
select * from submissions;

with recursive cte as (
select distinct submission_date,hacker_id from submissions
where submission_date=(select min(submission_date) from submissions)
union
select s.submission_date,s.hacker_id from submissions s
join cte on cte.hacker_id=s.hacker_id
where s.submission_date=(select min(submission_date) from submissions 
where submission_date>cte.submission_date)
),
unique_hacker as(
select submission_date,count(hacker_id) as no_of_unique from cte
group by submission_date
order by 1) ,
count_sub as (
 select submission_date,hacker_id,count(1) as no_of_sub
 from submissions
 group by submission_date,hacker_id 
 order by 1
 ),
 max_sub as (
 select submission_date,max(no_of_sub) as max_sub from count_sub
 group by submission_date
 ), 
 final_hacker as (
 select c.submission_date,min(c.hacker_id) as hacker_id from max_sub m
 join count_sub c
 on m.submission_date=c.submission_date and m.max_sub=c.no_of_sub
 group by c.submission_date
 order by 1)
 
 select uh.submission_date,uh.no_of_unique,fh.hacker_id,h.name
 from unique_hacker uh
 join final_hacker fh
 on uh.submission_date=fh.submission_date
 join hackers h
 on h.hacker_id=fh.hacker_id
 order by 1
;