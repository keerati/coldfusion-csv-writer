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
      }); 

      afterEach(function() {
        if (IsDefined("tempFile")) {
          tempFile.delete();
        }
      });

      it('Write successfully', function () {
        var writer = new lib.CSVWriter(
          outputQuery = outputQuery,
          outputPath = tempFile
        );
        var result = writer.write(); 
        expect(result).toBeTrue();
        expect(writer.getRecordCount()).toBe(5);
      });

      it('Write successfully using setBeforeWriteAllRecords to custom headers', function () {
        var writer = new lib.CSVWriter(
          outputQuery = outputQuery,
          outputPath = tempFile,
          withHeaders = false
        );
        writer.setBeforeWriteAllRecords(function(w) {
          w.write("e,f#writer.getNewLineChar()#");
        });
        var result = writer.write(); 
        expect(result).toBeTrue();
        expect(writer.getRecordCount()).toBe(5);
      });

    });

    describe('Write file with array of struct as an input', function() {
      beforeEach(function() {
        tempFile = CreateObject('java', 'java.io.File').createTempFile('test-csvwriter', '.csv');
        outputQuery = [
          {
            a = 'test',
            b = 1
          },
          {
            a = 'test2',
            b = 2
          }
        ];
        outputHeaders = ['a', 'b'];

      }); 

      afterEach(function() {
        if (IsDefined("tempFile")) {
          tempFile.delete();
        }
      });

      it('Throw error if outputHeaders is not provided', function () {
        expect( function() {
          var writer = new lib.CSVWriter(
            outputQuery = outputQuery,
            outputPath = tempFile
          );
        }).toThrow("InputValidation");
      });

      it('Write successfully', function () {
        var writer = new lib.CSVWriter(
          outputQuery = outputQuery,
          outputHeaders = outputHeaders,
          outputPath = tempFile
        );

        var result = writer.write(); 
        expect(result).toBeTrue();
        expect(writer.getRecordCount()).toBe(2);
      });

      it('Write successfully using setBeforeWriteAllRecords to custom headers', function () {
        var writer = new lib.CSVWriter(
          outputQuery = outputQuery,
          outputHeaders = outputHeaders,
          outputPath = tempFile,
          withHeaders = false
        );
        writer.setBeforeWriteAllRecords(function(w) {
          w.write("e,f#writer.getNewLineChar()#");
        });
        var result = writer.write(); 
        expect(result).toBeTrue();
        expect(writer.getRecordCount()).toBe(2);
      });

    });

  }
}
