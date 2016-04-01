#!/usr/bin/env bash

retrolambda_jar=$1
android_classpath=$2
in_dir=$3
out_dir=$4

# loop through all the jars within in_dir and run retrolambda on them all
for old_jar in $(find -L $in_dir -name *.jar); do
    # extract the old jar to get at our classes
    classes_dir=$old_jar.classes
    unzip $old_jar -d $classes_dir

    # run retrolambda on its classes
    java -Dretrolambda.inputDir=$classes_dir -Dretrolambda.classpath=$old_jar:$android_classpath -javaagent:$retrolambda_jar -jar $retrolambda_jar

    # map our jar path from our in dir to our out dir
    new_jar=${old_jar//$in_dir/$out_dir}
    mkdir -p `dirname $new_jar`

    # archive up our processed classes
    jar -cf $new_jar -C $classes_dir .
done

# loop through all the linked directories in our bin dir
for link in $(find $in_dir/buck-out/bin -type l); do
    # we expect each link to be a directory containing class files
    inpath=`readlink $link`
    outpath=${link//$in_dir/$out_dir}

    # run retrolambda on the classes
    java -Dretrolambda.inputDir=$inpath -Dretrolambda.outputDir=$outpath -Dretrolambda.classpath=$classdir:$android_classpath -javaagent:$retrolambda_jar -jar $retrolambda_jar
done

