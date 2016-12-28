# Coldfusion CSV Writer module ![](https://circleci.com/gh/keerati/coldfusion-csv-writer.png?circle-token=f64759dfa35cbda7da54544ac668c6ce82820e61)

Write a Query object or Array of Struct to specific path using java.io.FileWriter.

### To run unit tests
- Make sure [Testbox](http://www.ortussolutions.com/products/testbox) is on wwwroot folder.
- Run tests/runner.cfm file to see the result.

### Example
```cfc
<cfscript>
  outputQuery = QueryNew('a, b', 'cf_sql_varchar, cf_sql_integer');
  for (var i = 1; i <= 5; i++) {
    QueryAddRow(q);
    QuerySetCell(q, 'a', JavaCast('string', "test#i#"));
    QuerySetCell(q, 'b', JavaCast('int', i));
  }

  writer = new CSVWriter(
    outputQuery = outputQuery,
    outputPath = "/path/to/output/file"
  );
  writer.write();
</cfscript>
```
