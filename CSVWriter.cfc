component accessors = true {
  property name = 'query' getter = true setter = true;
  property name = 'headers' getter = true setter = true;
  property name = 'withHeaders' getter = true setter = true default = true;
  property name = 'delimiterChar' getter = true setter = true default = ',';
  property name = 'quoteChar' getter = true setter = true default = '"';
  property name = 'newLineChar' getter = true setter = true default = '#chr(13)##chr(10)#';
  property name = 'path' getter = true setter = true default = 'default.csv';
  property name = 'recordCount' getter = true setter = true default = 0;

  public any function init(
    required any outputQuery,
    required string outputPath,
    string delimiter,
    string quote,
    string newLine,
    array outputHeaders,
    boolean withHeaders
  ) {
    setPath(outputPath);

    setQuery(outputQuery);

    if (IsDefined('withHeaders')) {
      setWithHeaders(withHeaders);
    }
    if (!IsDefined('outputHeaders')) {
      var queryMetaData = GetMetaData(outputQuery);
      outputHeaders = getHeadersFromMetaData(queryMetaData);
    }
    setHeaders(outputHeaders);

    if (IsDefined('delimiter')) {
      setDelimiterChar(delimiter);
    }
    if (IsDefined('quote')) {
      setQuoteChar(quote);
    }
    if (IsDefined('newLine')) {
      setNewLineChar(newLine);
    }
    return this;
  }

  /* Inject functions */
  public void function setBeforeWriteAllRecords(any func) {
    variables.beforeWriteAllRecords = func;
  }

  public void function setAfterWriteAllRecords(any func) {
    variables.afterWriteAllRecords = func;
  }

  public void function setBeforeWriteEachRecord(any func) {
    variables.beforeWriteEachRecord = func;
  }

  public void function setAfterWriteEachRecord(any func) {
    variables.afterWriteEachRecord = func;
  }

  private void function beforeWriteAllRecords(any writer) {}

  private void function afterWriteAllRecords(any writer) {}

  private void function beforeWriteEachRecord(any writer, struct record) {}

  private void function afterWriteEachRecord(any writer, struct record, string writtenLine) {}
  /* End inject functions */

  public boolean function write() {
    var writer = CreateObject("java", "java.io.FileWriter").init(getPath()); 
    var successful = true;
    var newLine = getNewLineChar();
    try {
      beforeWriteAllRecords(writer);

      if (getWithHeaders()) {
        beforeWriteEachRecord(writer, {});

        var headerLine = makeCSVHeadersLine();
        writer.write(headerLine);

        afterWriteEachRecord(writer, {}, headerLine);

        writer.write(newLine);
      }

      for (var record in getQuery()) {
        beforeWriteEachRecord(writer, record);

        var line = makeCSVRecordLine(record);
        writer.write(line);
        setRecordCount(getRecordCount() + 1);

        afterWriteEachRecord(writer, record, line);

        writer.write(newLine);
      }

      afterWriteAllRecords(writer);
    } catch(any e) {
      // todo log error
      successful = false;
    } finally {
      writer.flush();
      writer.close();
    }

    return successful;
  }

  private array function getHeadersFromMetaData(array queryMetaData) {
    var headers = [];
    for (var metadata in queryMetaData) {
      ArrayAppend(headers, metadata.name); 
    }
    return headers;
  }

  private string function makeCSVHeadersLine() {
    return makeLine({}, function(header, record) {
      return header;
    });
  }

  private string function makeCSVRecordLine(struct record) {
    return makeLine(record, function(header, record) {
      return record[header];
    });
  }

  private string function makeLine(struct record, any getValueFunc) {
    var lineBuffer = CreateObject("java", "java.lang.StringBuffer");
    var delimiter = getDelimiterChar();
    var headers = getHeaders();
    var headersCount = ArrayLen(headers);
    for (var i = 1; i <= headersCount; i++) {
      var header = headers[i];
      var line = cleanValue(getValueFunc(header, record));
      lineBuffer.append(line);
      if (i != headersCount) {
        lineBuffer.append(delimiter);
      }
    }
    return lineBuffer.toString();
  }

  private string function cleanValue(string value) {
    var delimiter = getDelimiterChar();
    if (Find(delimiter, value) != 0) {
      var quote = getQuoteChar();
      value = "#quote##value##quote#";
    }
    return value;
  }
}
