var _member;

var buildHeader = function() {
  var header = {
    margin: 15,
    columns: [
      {
        width: '75%',
        columns: [
          {
            width: '25%',
            text: 'image'
          },
          {
            wdith: '*',
            text: 'text'
          }
        ]
      },
      {
        width: '*',
        text: 'Profile pic'
      }
    ]
  }

  return header;
}

var build = function() {
  var docDefinition = {
    pageSize: 'LETTER',
    pageMargins: [ 40, 60, 40, 60 ],
    header: buildHeader()
  }

  return docDefinition;
}

var execute = function(member) {
  console.log(member);

  _member = member;

  return build();
}

export default { execute: execute }
