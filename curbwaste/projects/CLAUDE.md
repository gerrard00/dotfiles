# Curbwaste Projects

Curbwaste builds tools to help companies manage orders and dispatch drivers to perform various tasks including dumpster removal, dumpster delivery, portapotty works, etc.

I specifically work on the Pod C team which focuses on dispatching and routing. 

## List

* curbwaste-web: the react/typescript web front-end for our project.
* curbwaste-backend: the new API. Controls updates to the database via migrations.
* curbwaste-apis: the older API, will still be in use for a long time.

## Data

The source of truth is a postgres database. We name our tables with plural names.

## Other

For each project I have a matching "-parallel". This is just another git work tree for the other repository. For example, curbwaste-web and curbwaste-web-parallel are the same project. Use either depending on the CWD at the time. 

For each project I have a matching "-review". This is just another git work tree for the other repository. For example, curbwaste-web and curbwaste-web-review are the same project. I use the review trees exclusively for reviewing code written by my teammates.
