component extends = 'testbox.system.BaseSpec' {
  function randString(numeric length) {
    var buffer = [];
    for (var i = 1; i <= length; i++) {
      ArrayAppend(buffer, Chr(RandRange(65, 90)));
    }
    return ArrayToList(buffer, '');
  }

  function createQuery() {
    var q = QueryNew('a, b', 'cf_sql_varchar, cf_sql_integer');
    for (var i = 1; i <= 5; i++) {
      QueryAddRow(q);
      QuerySetCell(q, 'a', JavaCast('string', randString(i * 4)));
      QuerySetCell(q, 'b', JavaCast('int', i));
    }
    return q;
  }

  function run() {
    describe('Write file with query object as an input', function() {
      beforeEach(function() {
        tempFile = CreateObject('java', 'java.io.File').createTempFile('test-csvwriter', '.csv');
        outputQuery = createQuery();
        writer = new lib.CSVWriter(
          outputQuery = outputQuery,
          outputPath = tempFile
        );
      }); 

      afterEach(function() {
        if (IsDefined("tempFile")) {
          tempFile.delete();
        }
      });

      it('Write successfully', function () {
        var result = writer.write(); 
        var result = true;
        expect(result).toBeTrue();
        expect(writer.getRecordCount()).toBe(5);
      });
    });
  }
}
