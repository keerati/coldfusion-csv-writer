component accessors = true {
  property name = 'query' getter = true setter = true;
  property name = 'writer' getter = true setter = true;
  property name = 'headers' getter = true setter = true;
  property name = 'withHeaders' getter = true setter = true default = true;
  property name = 'delimiterChar' getter = true setter = true default = ',';
  property name = 'quoteChar' getter = true setter = true default = '"';
  property name = 'newLineChar' getter = true setter = true default = '#chr(13)##chr(10)#';
  property name = 'path' getter = true setter = true default = 'default.csv';
  property name = 'recordCount' getter = true setter = true default = 0;

  public any function init(
    required any outputQuery,
    required any outputPath,
    array outputHeaders,
    boolean withHeaders,
    string delimiter,
    string quote,
    string newLine
  ) {
    setPath(outputPath);

    setQuery(outputQuery);

    if (IsDefined('withHeaders')) {
      setWithHeaders(withHeaders);
    }
    if (!IsDefined('outputHeaders')) {
      if (!IsQuery(outputQuery)) {
        throw(type = "Object", message = "If the outputQuery is not a Query, outputHeader is required.")
      }
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
    var lineBuffer = [];
    var headers = getHeaders();
    for (var header in headers) {
      var value = cleanValue(getValueFunc(header, record));
      ArrayAppend(lineBuffer, value);
    }
    return ArrayToList(lineBuffer, getDelimiterChar());
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
