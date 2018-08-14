/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
Ans:
SELECT * 
FROM  Facilities
WHERE membercost >0

/* Q2: How many facilities do not charge a fee to members? */
Ans:
SELECT COUNT( * ) 
FROM  Facilities
WHERE membercost =0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
Ans:
SELECT facid, name, membercost, monthlymaintenance
FROM  Facilities
HAVING monthlymaintenance * 0.2 > membercost


/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
Ans:
SELECT * 
FROM  Facilities 
WHERE facid
IN ( 1, 5 )

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
Ans:
SELECT name, monthlymaintenance,
case when monthlymaintenance > 100 then 'expensive'
else 'cheap' end as label
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
Ans:
SELECT firstname, surname
FROM Members
where joindate = (select max(joindate) from Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
Ans:
SELECT distinct fa.name as facilities_name, concat(me.surname,' ', me.firstname) as member_name
FROM country_club.Bookings as bo, country_club.Facilities as fa,country_club.Members as me
where bo.facid = fa.facid 
and bo.memid = me.memid
and fa.name like '%Tennis Court%'
order by member_name, facilities_name

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
Ans:
SELECT fa.name as facility_name, concat(me.firstname,' ', me.surname) as member_name,
case when bo.memid>0 then fa.membercost*bo.slots /*Calculate Member Cost*/
else fa.guestcost*bo.slots /*Calculate Guest Cost*/
end as cost
FROM Bookings as bo, Facilities as fa, Members as me
where bo.facid = fa.facid and bo.memid = me.memid and bo.starttime like '2012-09-14%'
order by cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
Ans:
select T1.facility_name, T1.member_name, T1.cost
from
/*Calculate the cost for Guest ONLY*/
(select t1.bookid,t1.facility_name, t1.member_name,t1.slots * t1.guestcost as cost
from
(SELECT bo.bookid,bo.facid, bo.memid, bo.slots, fa.guestcost, fa.name as facility_name, concat(me.firstname,' ',me.surname)  as member_name
FROM Bookings as bo, Facilities as fa, Members as me
where bo.starttime like '2012-09-14%'and bo.memid = 0 and bo.facid = fa.facid and bo.memid= me.memid ) as t1
union
/*Calculate the cost for Member ONLY*/
select  t2.bookid,t2.facility_name, t2.member_name,t2.slots * t2.membercost as cost
from
(SELECT bo.bookid,bo.facid, bo.memid, bo.slots, fa.membercost, fa.name as facility_name, concat(me.firstname,' ',me.surname)  as member_name
FROM Bookings as bo, Facilities as fa, Members as me
where bo.starttime like '2012-09-14%'and bo.memid > 0 and bo.facid = fa.facid and bo.memid= me.memid ) as t2) as T1
order by T1.cost DESC

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
Ans:
/*Final SQL filter out all the facility more than $1000 revenue*/
select t2.facility_name, t2.revenue
from
(
/*Sum up all the cost as revenue an group by facility_id*/
select t1.facility_id, t1.facility_name, t1.cost, sum(t1.cost) as revenue
from
(
/*Calculate cost of each member and guest*/
SELECT distinct bo.bookid as book_id,fa.facid as facility_id,fa.name as facility_name, concat(me.firstname,' ', me.surname) as member_name,
case when bo.memid>0 then fa.membercost*bo.slots /*Calculate Member Cost*/
else fa.guestcost*bo.slots /*Calculate Guest Cost*/
end as cost
FROM Bookings as bo, Facilities as fa, Members as me
where bo.facid = fa.facid and bo.memid = me.memid 
order by book_id DESC
) as t1
group by facility_id
) as t2
where t2.revenue < 1000


