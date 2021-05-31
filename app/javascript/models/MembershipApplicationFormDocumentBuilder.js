var _member;

var build = function() {
  var docDefinition = {
  }

  return docDefinition;
}

var execute = function(member) {
  console.log(member);

  _member = member;

  return build();
}

export default { execute: execute }
