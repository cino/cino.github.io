+++
author = "Ricardo Cino"
title = "AWS Learning badge assignments"
slug = "aws-learning-badge-assignments"
date = "2023-02-10"
tags = [
    "aws",
    "amazon web services",
    "learning",
    "skill builder",
    "badges",
    "achievements"
]
+++

Besides the AWS Certification program, there are also the newer AWS Learning skill badges. A new-ish way of learning the skills necessary to work on the aws platform and illustrate your knowledge. These are like the certifications except they are **not** certifications of some kind and you can take exams to receive the "Skill badge", this is all for free and is here to help you. I finished them all and wanted to highlight each of them, and how I experienced each of the exams.

<!--more-->

## What are the topics?

Like there is with the Certifications there are a select amount of topics on what you can achieve a Learning Badge, at the time of writing there are 10 different badges to achieve while making 8 different exams. 2 of those badges are awarded when you finish different levels of storage-related skill paths.

The way I see it there are 5 different learning paths as there are three exams you need to finish before you receive the "Storage Core" path, and another two to receive the "Storage Technologist" path. Combined you need to have finished all 5 storage exams before receiving the ultimate Storage Technologist badge. The other badges are separate, single-exam paths.

## Why did I take these?

Even though I already have multiple AWS Certifications which cover most of these topics I'm still preparing for the <a href="https://aws.amazon.com/certification/certified-solutions-architect-professional/" target="_blank" title="AWS Certified Solutions Architect - Professional">AWS Certified Solutions Architect - Professional</a> exam. My way of learning is mostly about repetition, so doing these learning paths will hopefully help me remember some of the specifics I'm not dealing with day-to-day.

## The Paths

As mentioned, I look at them as 5 different paths, with the storage paths having multiple exams to receive the combined badge. Let's go through them 1 by 1, in order that they've been released.

### AWS Learning: Storage Core

In general this section is about the 3 different kind of storage options and you should be able to choose which option you would use in which situation.

**Object**

When you say Object storage all I see is S3 . This is all about S3 and touches all the aspects. The different storage classes, pricing, security, optimization and a bit of disaster recovery. Because Amazon S3 is one of the biggest AWS services you will most definitely use this when working on AWS and it would be wise to know all about it.

**Block**

Elastic Block Storage, the default storage when using Amazon EC2 instances, this is about that. As with S3 it is about how to use it, optimization (cost/performance), security, and how and when to use which type of storage. When using EBS there are multiple limiting factors that could slow down your application, you'll need to be able to debug such scenario's and recommend the correct setup based on specified needs.

**File**

Amazon Elastic File System is another one of those services that I don't regularly use. However, the main part of this learning path is explaining the different ways of using Amazon EFS and which option you choose. There are different EFS options for working with windows/linux and knowing what to use is highly important. Besides how the storage is utlized you also learn about migrating data from your on-premise which you'll also see in the specific migration section later on.

### AWS Learning: Storage Technologist

**Data Protection & Disaster Recovery**

Inevitable for when you are planning to architect larger-scale applications on Amazon Web Services. You need to think about your data protection & disaster recovery. This learning plan takes you through the different options available within AWS. I would recommend following this when you plan to go for any of the Solution Architect certificates as this is something that they will ask, also, it is quite handy to know about this for your next multi-region project.

**Data Migration**

This was for me a topic that I had less experience with, as generally I'm building web based / api driven applications on AWS where I didn't need to migrate any data to AWS it was quite new to me. There are many services mentioned in this learning path which explain how to migrate data to AWS including the differences in the Snow family and how to migrate data from your on-premise hardware to the cloud. Being able to differentiate the options on a cost and time effective basis is required.

### AWS Learning: Serverless

Released during AWS RE:Invent 2022 this was for me the skill badge that introduced me to the this part of AWS Learning, there were lots of people suddenly sharing the achievement of this on LinkedIn and that gave the AWS Learning program a lot of attention.

The name implies this is all about Serverless, looking at the different serverless services including but not only, Lambda/DynamoDb/S3/Fargate/Aurora Serverless/CloudWatch/API Gateway. The total package on working in the serverless landscape if you ask me and I would **highly recommend** following this learning path if you intend on working with AWS Serverless.

### AWS Learning: AWS for Games: Cloud Game Development

Because I'm a bit weird, I tend to try the exam first (free retries) and without any game development experience on AWS I was able to achieve this assessment. Which makes me wonder who this assessment is actually for. The number of questions specific to AWS Gaming services was limited or you could easily pick out which answers weren't correct. Most questions are related to general aws knowledge and being able to decide what architecture is best for gaming environments.

If it were up to me I would drastically change this exam as I don't believe it demonstrates that you have experience with the AWS Gaming services.

### AWS Learning: Architecting

The hardest one of the 5, this is a perfect "test exam" before you go on to your <a href="https://aws.amazon.com/certification/certified-solutions-architect-associate/" target="_blank" title="AWS Certified Solutions Architect - Associate">AWS Certified Solutions Architect - Associate</a> as this is actually at the end of the Learning plan that is designed for the certificate.

Ultimately the best course of action would be to look into the others first before doing this one, if you have more knowledge about the storage / serverless paths you find this one to be easier. It's a requirement to have some understanding of storage, migration, and disaster recovery if you want to architect on AWS.

As already mentioned, this is in my opinion a perfect "practice exam" for the real associate.

## Summary

In general, I believe this to be an excellent way of learning the AWS Services and the quirks around them. Besides the AWS For Games learning path, they help you represent that you have knowledge of the subjects and can most definitely help you further along your certification journey.
