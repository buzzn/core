# scope on models

scope are chainable sql queries. unfortunately active-record (AR) has only limited functionallity regarding SQL. to get the complete SQL functionality AREL is used most of the time and sometimes even plain text SQL statements.

## joins vs. exists

in short joins produces an product of two tables (like a set of all pairs of table elements) and the 'ON' clause filters this set with some condition. usually you get double and multiple entries of a table in the result which needs a 'DISTINCT' to reduce it. this blowup and reduction is hint that the query looks are too many elements.

using 'EXISTS' queries can reduce the amount of visited elements altogether.

see https://danmartensen.svbtle.com/sql-performance-of-join-and-where-exists

## AREL syntax on exists queries

`project(1).exists` on an AREL statement will produce
```
EXISTS SELECT 1 ....
```

for having an `user` and select all register where the group is readable by the given user. first take all readable groups
```
Group.readable_by(user)
```
and now make it a subquery

```
Group.readable_by(user).where(group[:id].eq(register[:group_id]))
```
here the `group[:id]` belongs to the `Group.readable_by(user)` and `register[:group_id])` to the outer registers table. making this an AR query
```
Register.where(Group.readable_by(user).where(group[:id].eq(register[:group_id])).project(1).exists.to_sql)
```
this gives the SQL
```
SELECT * FROM registers WHERE EXISTS ( SELECT 1 WHERE ... AND groups.id = registers.id )
```

now you can add more conditions in an either-or manner. add a manager or admin condition:
```
Register.where(Group.readable_by(user).where(group[:id].eq(register[:group_id])).project(1).exists.to_sql + ' OR ' + User.roles_query(user, manager: register[:id], admin: nil).project(1).exists.to_sql)
```

this means either you get all registers where the given user belongs to readble group of a register or is manager/admin of a register.

## readble_by? methods on models

this just extends the `readable_by(user)` scope by limiting the query to the given resource and then verify that the count is 1. with the above register example adding
```
where('registers.id = ?', resource.id).count == 1
```
will give
```
Register.where(Group.readable_by(user).where(group[:id].eq(register[:group_id])).project(1).exists.to_sql + ' OR ' + User.roles_query(user, manager: register[:id], admin: nil).project(1).exists.to_sql).where('registers.id = ?', resource.id).count == 1
```
