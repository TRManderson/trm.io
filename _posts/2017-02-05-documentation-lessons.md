---
layout: post
title:  "Lessons Learned from Not Documenting"
date:   1970-01-01 00:00:00 +1000
categories: 
---

In this post I'm discussing lessons I've learned about documentation where I really should have been doing something, but haven't been. Every single lesson is, at the time of writing, something I am about to implement, or have implemented within the last week. Every single one is something I see immense value in. Every single section has concrete implementation steps at the bottom.

Documenting Processes
------------------

Until recently, my role at work was primarily a devops one, and thus involved a whole lot of processes. Being young and reckless, I pretty consistently took the "just play with it until it works" approach, which was honestly good enough at the time. Now, after stepping back and handing a lot of the devops workload to someone else, the importance of documenting processes has dawned on me.

This lesson only really hit me with the recent [Gitlab database incident](https://docs.google.com/document/d/1GCK53YDcBWQveod9kfzW-VCxIABGiryG7_z_6jHdVik/pub), where they lost their production database to a stray `rm -rf` that was accidentally run on prod instead of staging. The incident itself wasn't what really drove the point home, it was [this comment by gizmo](https://news.ycombinator.com/item?id=13537177) on the [Hacker News thread](https://news.ycombinator.com/item?id=13537052).

>This is painful to read. It's easy to say that they they should have tested their backups better, and so on, but there is another lesson here, one that's far more important and easily missed.
>
>When doing something really critical (such as playing with the master database late at night) ALWAYS work with a checklist. Write down WHAT you are going to do, and if possible, talk to a coworker about it so you can vocalize the steps. If there is no coworker, talk to your rubber ducky or stapler on your desk. This will help you catch mistakes. Then when the entire plan looks sensible, go through the steps one by one. Don't deviate from the plan. Don't get distracted and start switching between terminal windows. While making the checklist ask yourself if what you're doing is A) absolutely necessary and B) risks making things worse. Even when the angry emails are piling up you can't allow that pressure to cloud your judgment.
>
>Every startup has moments when last-minute panic-patching of a critical part of the server infrastructure is needed, but if you use a checklist you're not likely to mess up badly, even when tired.

This really seemed remarkably sane to me.

When setting up a new machine, you should have a documented process, and ideally it should be automated. If it's automated, you'll still probably be invoking some arcane script that does some magic, and that magic should be documented. You should know exactly what each command does before you run it. When starting development on a new project, you should be able to follow a checklist to get everything up to speed, or automate it. When doing a production release, checklist or automate.

Up until now I've been basically of the mind that "configuration management is all the documentation I need", which really isn't true at all. We're dealing with interacting components, not some immutable building block.


My plan from now when developing a process:
 - Write down every action before I take it;
 - Talk each action over with a colleague -- they seem to be pretty good at spotting my stupid mistakes;
 - Write down the result after I take each action;
 - When I'm done writing down and trying every step of the process, automate it.

Especially important:
 - I'll add human checks to the automated process, to be removed at a later date when confidence has been established.


Documenting Changes (and versions)
-------------------

Up until recently, everyone at the office would participate in a daily standup, where everyone would hear what was going on in each project in the business -- this included our shared data visualisation framework (where the bulk of my work is). The company has now grown large enough that everyone hearing everything is infeasible, so we've broken the daily down into team meetings. The very first thing that was said after we first tried this was basically as follows:

> Hey, seeing as we don't get to hear what you guys are working on day to day, it'd be really good to get like an email or something to let us know what you've been working on.

So basically a changelog...

Being able to see what's changed in a version upgrade of a project, or even between commits (without having to read commit messages), is a really useful debugging tool, a nice way to communicate progress, and even an opportunity to [have a bit of fun](https://api.slack.com/changelog).

The worst part is, [versioning releases](http://semver.org/) and documenting changes is really such a trivial and useful thing. It's as simple as keeping a "CHANGELOG.md" in your git repo, and making sure every pull request you do updates it (Haven't got a pull request workflow? Just start doing it and never merge your changes until people review them). After a release, start a new heading for the next version, add your changes there. Need to do hotfixes? Start a branch from where you released last. Super simple stuff.

Want to step it up a notch? Have a dev blog where you do reader-friendly writeups of large changes (or even writeups of challenging bugfixes).


High-level documentation
------------------------

I have a tendency to document my work at the API level, and no higher. I can plainly say that this is a recipe for disaster. When all you've got are type annotations and a brief description of what a function does, it becomes very unclear how to actually interact with an API until you have a play with it and trigger a few errors. I think everyone has dealt with a poorly documented library at some stage, and I think this is a large part of what causes it.

Some of the best documentation I've seen is the [SQLAlchemy reference](http://docs.sqlalchemy.org/en/rel_1_1/), which starts from the high level with basic usage, then drills down section by section about how to use various parts of the tool - ORM mappers, the Session API (not just API documentation, but how to use it, and how components interact). On top of this, there's *really* in-depth API documentation too.

Pretty much everyone agrees that documentation is good, but pretty universally, people under-document. I have a slight suspicion that this is basically due to two things: underestimating [inferential distance](https://wiki.lesswrong.com/wiki/Inferential_distance) on work you're familiar with, and high cycle-time for documentation.

The first is pretty concrete: people are familiar with the things they work on, and due to bog-standard human biases, we forget that other people aren't as familiar. On documentation cycle times, we frequently test our code, but it's far less common to do similar things with our documentation. In my workplace, we do documentation builds on our CI server but nobody even considers building documentation before pushing code, and nobody really reads it once it's out there (besides our poor, poor users).

Both these issues are really hard to address, but I think there's a few things we can do at the very least.
 - Make sure every pull request that adds a new feature also adds new documentation
 - Ensure a minimum level of API documentation
 - Try and encourage code reviewers to also review your documentation
 - Force every changelog item (you're doing those now, right?) to include a link to documentation

If I knew of any tools like this, I'd no doubt be suggesting some sort of linter for documentation. I don't think a spelling and grammar check would do the job, mainly due to the large quantities of non-standard language that gets used in documentation.

Final Thoughts
-------------

I'm really starting to see documentation as part of taking pride in my work, and part of being able to actually call my work "finished". It would be hypocritical of me to call out developers for writing unreliable software if I'm here writing unmaintainable software, or establishing unsustainable processes due to sheer laziness. Getting documentation right really isn't too hard, and I've really come to see that really is worth the effort.
