/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS */
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */ 

SELECT name
FROM Facilities
WHERE MemberCost > 0
/* Tennis Court 1, Tennis Court 2, Message Room 1, Massage Room 2, Squash Court */

/* Q2: How many facilities do not charge a fee to members? */

SELECT Count(*)
FROM Facilities
WHERE MemberCost = 0
/* 4 */

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost < (monthlymaintenance * 0.2)
/* All of them (9) */

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid in (1,5)
/* Massage Room 2 (facid 5) and Tennis Court 2 (facid 1)*/

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

/* Think this could have a couple different solutions. Assuming the below based off of later questions. */
SELECT name, monthlymaintenance, ( CASE
		WHEN monthlymaintenance > 100 THEN 'expensive'
		ELSE 'cheap'
     END ) AS label
FROM Facilities
ORDER BY monthlymaintenance desc
/*
 name
monthlymaintenance
label
Massage Room 1
3000
expensive
Massage Room 2
3000
expensive
Tennis Court 1
200
expensive
Tennis Court 2
200
expensive
Squash Court
80
cheap
Badminton Court
50
cheap
Snooker Table
15
cheap
Pool Table
15
cheap
Table Tennis
10
cheap
 */

/* However, it could also be changing just the column 'name' using as */
SELECT name as expensive, monthlymaintenance
FROM Facilities
WHERE monthlymaintenance > 100
ORDER BY monthlymaintenance desc
/* Has the 2 massage rooms and tennis courts (4 total) */
SELECT name as cheap, monthlymaintenance
FROM Facilities
WHERE monthlymaintenance < 100
ORDER BY monthlymaintenance
/* Table Tennis, Snooker Table, Pool Table, Badminton Court, Squash Court. */

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX(joindate)
    FROM Members
    )
/* Darren Smith (there are multiple) on 2012-09-26 18:08:45 */

/* Simpler to do with limit. */
SELECT firstname, surname
FROM Members
ORDER BY joindate desc
LIMIT 1


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(m.firstname, ' ', m.surname) AS fullname, f.name
FROM Members AS m
JOIN Bookings AS b ON b.memid = m.memid
JOIN Facilities AS f ON b.facid = f.facid
WHERE f.facid
IN (
    SELECT facid
	FROM Facilities
	WHERE name LIKE '%tennis court%'
)
ORDER BY fullname
/* 46 records. Some of the names are duplicated because they played on both tennis courts. */

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT DISTINCT 
	f.name, 
	CONCAT( m.firstname, ' ', m.surname ) AS fullname, 
	( CASE
		WHEN m.memid = 0 THEN (f.guestcost * b.slots)
		ELSE (f.membercost * b.slots)
     END ) AS cost										
FROM Members AS m
JOIN Bookings AS b ON b.memid = m.memid
JOIN Facilities AS f ON b.facid = f.facid
WHERE 
    b.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'
		AND 
		    m.memid = 0 AND (f.guestcost * b.slots) > 30
		OR
		    m.memid != 0 AND (f.membercost * b.slots) > 30
ORDER BY cost DESC
/* 
18 results
name
fullname
cost Descending
Massage Room 2
GUEST GUEST
320.0
Massage Room 1
GUEST GUEST
160.0
Tennis Court 2
GUEST GUEST
150.0
Tennis Court 2
GUEST GUEST
75.0
Tennis Court 1
GUEST GUEST
75.0
Squash Court
GUEST GUEST
70.0
Tennis Court 1
Nancy Dare
45.0
Tennis Court 2
Tim Boothe
45.0
Massage Room 1
Jemima Farrell
39.6
Massage Room 1
Tim Rownam
39.6
Massage Room 1
Timothy Baker
39.6
Massage Room 1
Darren Smith
39.6
Massage Room 1
Tim Boothe
39.6
Massage Room 1
Ponder Stibbons
39.6
Massage Room 1
David Jones
39.6
Massage Room 1
Gerald Butters
39.6
Massage Room 1
Matthew Genting
39.6
Squash Court
GUEST GUEST
35.0
   */

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

/* While I was building this sql.springboard became unavailable. Think it will be similar to the below and the performance will be very slow.*/
SELECT DISTINCT
	f.name,
	CONCAT( m.firstname, ' ', m.surname ) AS fullname,
	( CASE
		WHEN m.memid = 0 THEN (f.guestcost * b.slots)
		ELSE (f.membercost * b.slots)
     END ) AS cost
FROM Facilities AS f, Bookings AS b, Members AS m
WHERE f.facid IN (
    SELECT b.facid 
    FROM Bookings as b
    WHERE 
		b.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'
		AND 
			m.memid = 0 AND (f.guestcost * b.slots) > 30
			OR
			m.memid != 0 AND (f.membercost * b.slots) > 30
	AND
		b.facid IN (
            SELECT m.memid
            FROM Members AS m
            WHERE b.memid = m.memid AND b.facid = f.facid
        )
)
ORDER BY cost DESC

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */


/* Q12: Find the facilities with their usage by member, but not guests */


/* Q13: Find the facilities usage by month, but not guests */

