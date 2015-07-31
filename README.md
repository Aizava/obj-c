## obj-c
#Movie to gif convertation

This tiny class can convert .mov file into .gif with params.

#Params
NSURL* path; - movie path
NSURL* finishPath; - save path
int fps; - frames per seconds. Don't set it to 30 or more
int quality; - quality from 1 to 100

//trimming params
double T1; - Start time
double T2; - finish time

NSSize size; - origin size of movie (width / height)


