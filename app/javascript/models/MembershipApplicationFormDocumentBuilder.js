var _member;

var fontSizeDefault   = 9;
var fillColorDefault  = 'yellow';

var styleDefault = {
  fontSize: 9
}

var styleBoldDefault = {
  fontSize: 9,
  bold: true
}

var styleEmphDefault = {
  fontSize: 9,
  bold: true,
  italics: true
}

var styleEmphSecondary = {
  fontSize: 7,
  bold: true,
  italics: true
}

var styleSmall = {
  fontSize: 7
}

var styleSectionHeader = {
  fontSize: 9,
  bold: true,
  margin: [0, 0, 0, 10]
}

var styleCellLabel = {
  fontSize: 7,
  fillColor: fillColorDefault
}

var styleCellValue = {
  fontSize: 7
}

var styleCellCenteredLabel = {
  fontSize: 7,
  fillColor: fillColorDefault,
  alignment: 'center',
  bold: true
}

var _generateApplicationSignatory = function() {
  var context = 'Aking pinatotohanan na ang lahat ng impormasyong aking isinulat ay pawang katotohanan sa abot ng aking paniniwala at kaalaman. Anumang maling impormasyon, pagtatago o kasinungalingan ay magiging sapat na dahilan para ako ay matiwalag sa pagiging miyembro ng K-Coop.\n\n'

  context += 'Bilang miyembro ay kinikilala at pinapahintulutan ko ang mga sumusunod:\n';

  var obj = {
    table: {
      margin: [0, 20, 0, 0],
      widths: ["100%"],
      body: [
        [
          { text: context, style: styleSmall, alignment: 'justify', border: [true, true, true, false] }
        ],
        [
          { 
            ol: [ 
              'Kaakibat ng aking aplikasyon sa pagiging miyembro, aking pinahihintulutan ang pag-kolekta at pag-proseso ng aking mga impormasyon alinsunod sa R.A. No. 10173 o Data Privacy Act of 2012.',
              'Regular na pagpapasa at pagpapahayag ng aking Basic Credit Data alinsunod sa R.A. No. 9510 o “Credit Information System Act” s a Credit Information Corporation (CIC) pati ang mga pagbabago o pagtatama nito;',
              'Pagbabahagi ng aking Basic Credit Data sa iba pang institusyong nagpapautang at iba pang mga ahensiya na may kinalaman sa pagpapautang na pinahihintulutan ng R.A. No. 10173 at R.A. No. 9510.'
            ], 
            style: styleSmall,
            border: [true, false, true, false]
          }
        ],
        [
          {
            text: 'Nauunawaan ko din ang polisiya ng K-Coop at handa akong sumunod sa mga alintuntunin nito gaya ng mga sumusunod:',
            style: styleSmall,
            alignment: 'justify',
            border: [true, false, true, false]
          }
        ],
        [
          {
            ol: [
              'Pagdalo sa meeting',
              'Pagsama sa sitdown',
              'Pagpayag masitdown',
              'Pagsunod sa 1 day before meeting policy sa paghuhulog',
              'Pag-iimpok linggu-linggo',
              'Pagpapamiyembro sa K-MBAA',
              'Pagtupad sa obligasyon sa co-maker'
            ],
            style: styleSmall,
            border: [true, false, true, false]
          }
        ],
        [
          {
            table: {
              margin: [0, 0, 0, 0],
              widths: ["50%", "50%"],
              body: [
                [
                  { text: '', border: [false, false, false, false] },
                  {
                    text: 'Pangalan at Lagda ng Aplikante', border: [false, true, false, false], style: styleBoldDefault, alignment: 'center'
                  }
                ]
              ]
            },
            style: styleSmall,
            border: [false, false, false, false]
          }
        ]
      ]
    }
  }

  return obj;
}

var _generateChildrenTable  = function() {
  var body = [
    [
      {
        text: 'PERSONAL NA IMPORMASYON NG MGA ANAK',
        style: styleCellCenteredLabel,
        colSpan: 6
      }, {}, {}, {}, {}, {}
    ]
  ];

  body.push([
    {
      text: '#', style: styleCellCenteredLabel
    },
    {
      text: 'PANGALAN', style: styleCellCenteredLabel
    },
    {
      text: 'KAPANGANAKAN', style: styleCellCenteredLabel
    },
    {
      text: 'EDAD', style: styleCellCenteredLabel
    },
    {
      text: 'ANTAS NG PAG-AARAL', style: styleCellCenteredLabel
    },
    {
      text: 'KURSO', style: styleCellCenteredLabel
    }
  ]);

  for(var i = 0; i < 6; i++) {
    body.push([
      { text: '' + (i + 1), style: styleCellCenteredLabel },
      { text: '', style: styleCellValue },
      { text: '', style: styleCellValue },
      { text: '', style: styleCellValue },
      { text: '', style: styleCellValue },
      { text: '', style: styleCellValue }
    ])
  }

  var table = {
    margin: [0, 0, 0, 0],
    widths: ["5%", "40%", "15%", "5%", "20%", "15%"],
    body: body
  }

  return table;
}

var buildHeader = function() {
  var header = {
    margin: 20,
    columns: [
      {
        width: '75%',
        columns: [
          {
            width: '20%',
            text: 'image'
          },
          {
            wdith: '*',
            text: [
              { text: 'Kabuhayan sa Ganap na Kasarinlan Credit and Savings Cooperative\n', style: styleBoldDefault },
              { text: '4th Floor KMBA Members’ Center Building\n', style: styleSmall },
              { text: '5 Matimpiin Street, Barangay Pinyahan, Quezon City 1100\n', style: styleSmall },
              { text: 'Telephone Numbers: (632) 5310-2470/8442-9607; Fax Number: (632) 5310-2470 loc. 204\n', style: styleSmall },
              { text: 'CDA Reg. No.: 9520-1016000000028521\n', style: styleEmphDefault },
              { text: 'CIN: 16201628521\n', style: styleEmphSecondary }
            ]
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
    pageMargins: [20, 80, 20, 60],
    header: buildHeader(),
    content: [
      {
        text: 'APPLICATION FOR MEMBERSHIP', style: { bold: true, alignment: 'center' }
      },
      {
        text: 'Control No. ___________________', style: { fontSize: fontSizeDefault, alignment: 'right' }
      },
      {
        text: 'SASAGUTIN NG K-COOP', style: styleSectionHeader, margin: [0, 0, 0, 8]
      },
      {
        table: {
          margin: [0, 0, 0, 8],
          widths: ["25%", "25%", "25%", "25%"],
          body: [
            [
              {
                text: 'MEMBER / ID NUMBER', style: styleCellLabel
              },
              {
                text: '', style: styleCellValue
              },
              {
                text: 'DATE OF MEMBERSHIP', style: styleCellLabel
              },
              {
                text: '', style: styleCellValue
              }
            ],
            [
              {
                text: 'INITIAL SHARE CAPITAL', style: styleCellLabel
              },
              {
                text: '', style: styleCellValue
              },
              {
                text: 'MEMBERSHIP FEE', style: styleCellLabel
              },
              {
                text: '', style: styleCellValue
              }
            ],
            [
              {
                text: 'SATELLITE OFFICE', style: styleCellLabel
              },
              {
                text: '',
                colSpan: 3
              },
              {},
              {}
            ]
          ]
        }
      },
      {
        text: 'SASAGUTIN NG APLIKANTE', style: styleSectionHeader, margin: [0, 8, 0, 8]
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["25%", "25%", "25%", "25%"],
          body: [
            [
              { text: 'PERSONAL NA IMPORMASYON', style: styleCellCenteredLabel, colSpan: 2 },
              {},
              { text: 'TIRAHAN / ADDRESS', style: styleCellCenteredLabel, colSpan: 2 },
              {}
            ],
            [
              { text: 'PANGALAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'KALYE', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ],
            [
              { text: 'GITNANG PANGALAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'BRGY.', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["*", "*", "*", "*", "*", "*"],
          body: [
            [
              { text: 'PANGALAN NG NANAY SA PAGKADALAGA', style: styleCellCenteredLabel, colSpan: 6 },
              {},
              {},
              {},
              {},
              {}
            ],
            [
              { text: 'PANGALAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'GITNANG PANGALAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'APELYIDO', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["25%", "25%", "25%", "25%"],
          body: [
            [
              { text: 'URI NG PANINIRAHAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'TAGAL NA SA TIRAHAN (BILANG NG TAON / BUWAN)', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ],
            [
              { text: 'IPINAKITANG KATIBAYAN', style: styleCellLabel },
              { text: '', style: styleCellValue, colSpan: 3 }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["20%", "10%", "10%", "10%", "10%", "10%", "10%", "10%", "10%"],
          body: [
            [
              { text: 'KAPANGANAKAN', style: styleCellLabel },
              { text: 'TAON', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'BUWAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'ARAW', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'EDAD', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        },
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["25%", "25%", "25%", "25%"],
          body: [
            [
              { text: 'LUGAR NG KAPANGANAKAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'KASARIAN', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["15%", "55%", "10%", "20%"],
          body: [
            [
              { text: 'KATAYUANG SIBIL', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'RELIHIYON', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["20%", "10%", "20%", "*"],
          body: [
            [
              { text: 'BILANG NG ANAK', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'ILAN ANG NAG-AARAL', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["25%", "25%", "25%", "25%"],
          body: [
            [
              { text: 'CELLPHONE NUMBER', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'LANDLINE NUMBER', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ],
            [
              { text: 'KASALUKUYANG BANGKO (kung mayroon)', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'KLASE NG ACCOUNT', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["12.5%", "12.5%", "12.5%", "12.5%", "12.5%", "12.5%", "12.5%", "12.5%"],
          body: [
            [
              { text: 'SSS /GSIS #', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'PAG-IBIG #', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'PHILHEALTH #', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'TIN #', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: {
          margin: [0, 0, 0, 0],
          widths: ["25%", "25%", "25%", "25%"],
          body: [
            [
              { text: 'PERSONAL NA IMPORMASYON NG ASAWA O KINAKASAMA (COMMON-LAW SPOUSE)', style: styleCellCenteredLabel, colSpan: 4 },
              {},
              {},
              {}
            ],
            [
              { text: 'PANGALAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'KAPANGANAKAN', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ],
            [
              { text: 'GITNANG PANGALAN', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'EDAD', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ],
            [
              { text: 'APELYIDO', style: styleCellLabel },
              { text: '', style: styleCellValue },
              { text: 'TRABAHO', style: styleCellLabel },
              { text: '', style: styleCellValue }
            ]
          ]
        }
      },
      {
        table: _generateChildrenTable()
      },
      _generateApplicationSignatory()
    ]
  }

  return docDefinition;
}

var execute = function(member) {
  console.log(member);

  _member = member;

  return build();
}

export default { execute: execute }
