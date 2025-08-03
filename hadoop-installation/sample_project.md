## Sample Project: Word Count on Hadoop HDFS

#### Sample Dataset

```txt
Hadoop is an open source framework
Hadoop is used for Big Data processing
MapReduce is a core component of Hadoop
```

#### Create Project Directory and Sample Dataset

```bash
mkdir ~/hadoop-wordcount
cd ~/hadoop-wordcount
echo -e "Hadoop is an open source framework\nHadoop is used for Big Data processing\nMapReduce is a core component of Hadoop" > sample.txt
```

#### Word Count Java Code

Create a file named `WordCount.java` and add the following code:

```java
import java.io.IOException;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class WordCount {

    public static class TokenizerMapper extends Mapper<LongWritable, Text, Text, IntWritable> {

        private final static IntWritable one = new IntWritable(1);
        private Text word = new Text();

        public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {
            String[] words = value.toString().split("\\s+");
            for (String w : words) {
                word.set(w.replaceAll("[^a-zA-Z]", ""));
                if (!word.toString().isEmpty()) {
                    context.write(word, one);
                }
            }
        }
    }

    public static class IntSumReducer extends Reducer<Text, IntWritable, Text, IntWritable> {
        public void reduce(Text key, Iterable<IntWritable> values, Context context)
            throws IOException, InterruptedException {
            int sum = 0;
            for (IntWritable val : values) {
                sum += val.get();
            }
            context.write(key, new IntWritable(sum));
        }
    }

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "word count");
        job.setJarByClass(WordCount.class);
        job.setMapperClass(TokenizerMapper.class);
        job.setCombinerClass(IntSumReducer.class);
        job.setReducerClass(IntSumReducer.class);
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);
        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        System.exit(job.waitForCompletion(true) ? 0 : 1);
    }
}
```

#### Compile and Build JAR

```bash
mkdir classes
javac -classpath `hadoop classpath` -d classes WordCount.java
jar -cvf wordcount.jar -C classes/ .
```

#### Start HDFS service

```bash
start-dfs.sh
```

#### Put Input File in HDFS

```bash
hdfs dfs -mkdir -p /user/hadoop/wordcount-project/input
hdfs dfs -put sample.txt /user/hadoop/wordcount-project/input/
```

#### Run the WordCount Job

```bash
hadoop jar wordcount.jar WordCount \
    /user/hadoop/wordcount-project/input \
    /user/hadoop/wordcount-project/output
```

  * `/user/hadoop/wordcount-project/input` - HDFS input directory
  * `/user/hadoop/wordcount-project/output` - HDFS output directory (must not exist)

#### View Output

```bash
hdfs dfs -ls /user/hadoop/wordcount-project/output
hdfs dfs -cat /user/hadoop/wordcount-project/output/part-r-00000
```

#### Expected Output

```
Big 	1
Data	1
Hadoop  3
MapReduce   	1
component   	1
core	1
for 	1
framework   	1
is  	3
of  	1
open	1
processing  	1
source  1
used	1
```

#### Stop HDFS service

```bash
stop-dfs.sh
```