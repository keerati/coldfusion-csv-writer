component {
  this.name = "TestCSVWriter";
  this.mappings = {
    '/tests' = getDirectoryFromPath(getCurrentTemplatePath()),
    '/lib' = "#getDirectoryFromPath(getCurrentTemplatePath())#../"
  };
}
