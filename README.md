This repository is PoC code for AWS Glue crawler problem.

* AWS Glue: https://aws.amazon.com/glue/

## What problem?

AWS Glue can create glue data catalog by crawler.
Glue data catalog also can use as aws athena table.
However, in this case there is a problem that whatever query is executed will return emply result.

Suppose an object is placed in s3 as follows.
At this time, when glue crawler executes crawling to pattern_1, athena creates tables called group_csv and name_csv, respectively.

```
glue
└ pattern_1
  ├ group.csv
  └ name.csv

```

The contents of the file are as follows

```
==> group.csv <==
id,group
1,kagoshima
2,tokyo
3,okinawa
4,chiba
5,saitama
==> name.csv <==
id,name
1,takeru
2,maehara
3,hoge
4,huga
5,foge
```

Thus two files are a simple table that can be joined by id.
Of course athena's table made by crawler should have similar contents.
However, "SELECT *" return empty.

The workaround is to separate the directories for each table.

## PoC

You can reproduce by executing the following code.
Running the command creates a BUGGY table in athena.
So please try accessing the athena console and running the query(e.g. select *).

 * require
   * make, awscli

```
~/w/w/empty-return-athena-by-glue_crawler ››› make all
```

NOTE: This command put object your s3 bucket and create iam role. please see Makefile and _terraform/iam.tf


I'm hungry. so, I will write the details later.
