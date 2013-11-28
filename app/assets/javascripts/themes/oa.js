/**
 * OA theme for Highcharts JS
 */
Highcharts.theme = {
        colors: ["#514F78", "#42A07B", "#9B5E4A", "#72727F", "#1F949A", "#82914E", "#86777F", "#42A07B"],
        chart: {
                //className: 'skies',
                borderWidth: 0,
                plotShadow: true,
                //plotBackgroundImage: 'http://www.highcharts.com/demo/gfx/skies.jpg',
                plotBackgroundColor: {
                        linearGradient: [0, 0, 250, 500],
                        stops: [
                                [0, 'rgba(255, 255, 255, 1)'],
                                [1, 'rgba(255, 255, 255, 0)']
                        ]
                },
                plotBorderWidth: 1
        },
        title: {
                style: {
                        color: '#336666',//'#3E576F',
                        font: '16px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'
                }
        },
        subtitle: {
                style: {
                        color: '#336666',//color: '#6D869F',
                        font: '12px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'
                }
        },
        xAxis: {
                gridLineWidth: 0,
                lineColor: '#C0D0E0',
                tickColor: '#C0D0E0',
                labels: {
                        style: {
                                color: '#336666',//color: '#666',
                                fontWeight: 'bold'
                        }
                },
                title: {
                        style: {
                                color: '#336666',//color: '#666',
                                font: '12px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'
                        }
                }
        },
        yAxis: {
                alternateGridColor: 'rgba(255, 255, 255, .5)',
                lineColor: '#C0D0E0',
                tickColor: '#C0D0E0',
                tickWidth: 1,
                labels: {
                        style: {
                                color: '#336666',//color: '#666',
                                fontWeight: 'bold'
                        }
                },
                title: {
                        style: {
                                color: '#336666',//color: '#666',
                                font: '12px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'
                        }
                }
        },
        legend: {
                itemStyle: {
                        font: '9pt Trebuchet MS, Verdana, sans-serif',
                        color: '#336666',//color: '#3E576F'
                },
                itemHoverStyle: {
                        color: '#336666',//color: 'black'
                },
                itemHiddenStyle: {
                        color: '#336666',//color: 'silver'
                }
        },
        labels: {
                style: {
                        color: '#336666',//color: '#3E576F'
                }
        }
};

// Apply the theme
var highchartsOptions = Highcharts.setOptions(Highcharts.theme);
//-----------------------------------
// Highcharts.theme = {
	// //colors: ["#DDDF0D", "#7798BF", "#55BF3B", "#DF5353", "#aaeeee", "#ff0066", "#eeaaee",
	// //	"#55BF3B", "#DF5353", "#7798BF", "#aaeeee"],
	// colors: ["#514F78", "#42A07B", "#9B5E4A", "#72727F", "#1F949A", "#82914E", "#86777F", "#42A07B"],
	// chart: {
		// backgroundColor: {
			// /*
			// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
			// stops: [
				// [0, 'rgb(96, 96, 96)'],
				// [1, 'rgb(16, 16, 16)']
			// ]*/
			// linearGradient: [0, 0, 250, 500],
            // stops: [
                    // [0, 'rgba(255, 255, 255, 1)'],
                    // [1, 'rgba(255, 255, 255, 0)']
            // ]
		// },
		// borderWidth: 0,
		// borderRadius: 0,//15,
		// plotBackgroundColor: null,
		// //plotBackgroundColor: 'rgba(255, 255, 255, .9)',
		// plotShadow: false,
		// plotBorderWidth: 0
	// },
	// title: {
		// style: {
			// color: '#3E576F',//'#FFF',
			// font: '16px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'//'16px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
		// }
	// },
	// subtitle: {
		// style: {
			// color: '#6D869F',//color: '#DDD',
			// font: '12px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'//'12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
		// }
	// },
	// xAxis: {
		// gridLineWidth: 0,
		// lineColor: '#C0D0E0',
        // tickColor: '#C0D0E0',
		// //lineColor: '#999',
		// //tickColor: '#999',
		// labels: {
			// style: {
				// color: '#999',
				// fontWeight: 'bold'
			// }
		// },
		// title: {
			// style: {
				// color: '#AAA',
				// font: 'bold 12px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'//'bold 12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
			// }
		// }
	// },
	// yAxis: {
// /*		alternateGridColor: null,
		// minorTickInterval: null,
		// gridLineColor: 'rgba(255, 255, 255, .1)',
		// minorGridLineColor: 'rgba(255,255,255,0.07)',
		// lineWidth: 0,
		// tickWidth: 0,*/
		// alternateGridColor: 'rgba(255, 255, 255, .5)',
        // lineColor: '#C0D0E0',
        // tickColor: '#C0D0E0',
        // tickWidth: 1,
		// labels: {
			// style: {
				// color: '#999',
				// fontWeight: 'bold'
			// }
		// },
		// title: {
			// style: {
				// color: '#AAA',
				// font: 'bold 12px Franklin Gothic Medium, Franklin Gothic, ITC Franklin Gothic, Arial, sans-serif'//'bold 12px Lucida Grande, Lucida Sans Unicode, Verdana, Arial, Helvetica, sans-serif'
			// }
		// }
	// },
	// legend: {
		// itemStyle: {
			// color: '#CCC'
		// },
		// itemHoverStyle: {
			// color: '#FFF'
		// },
		// itemHiddenStyle: {
			// color: '#333'
		// }
	// },
	// labels: {
		// style: {
			// color: '#CCC'
		// }
	// },
	// tooltip: {
		// backgroundColor: {
			// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
			// stops: [
				// [0, 'rgba(96, 96, 96, .8)'],
				// [1, 'rgba(16, 16, 16, .8)']
			// ]
		// },
		// borderWidth: 0,
		// style: {
			// color: '#FFF'
		// }
	// },
// 
// 
	// plotOptions: {
		// series: {
			// shadow: true
		// },
		// line: {
			// dataLabels: {
				// color: '#CCC'
			// },
			// marker: {
				// lineColor: '#333'
			// }
		// },
		// spline: {
			// marker: {
				// lineColor: '#333'
			// }
		// },
		// scatter: {
			// marker: {
				// lineColor: '#333'
			// }
		// },
		// candlestick: {
			// lineColor: 'white'
		// }
	// },
// 
	// toolbar: {
		// itemStyle: {
			// color: '#CCC'
		// }
	// },
// 
	// navigation: {
		// buttonOptions: {
			// symbolStroke: '#DDDDDD',
			// hoverSymbolStroke: '#FFFFFF',
			// theme: {
				// fill: {
					// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
					// stops: [
						// [0.4, '#606060'],
						// [0.6, '#333333']
					// ]
				// },
				// stroke: '#000000'
			// }
		// }
	// },
// 
	// // scroll charts
	// rangeSelector: {
		// buttonTheme: {
			// fill: {
				// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
				// stops: [
					// [0.4, '#888'],
					// [0.6, '#555']
				// ]
			// },
			// stroke: '#000000',
			// style: {
				// color: '#CCC',
				// fontWeight: 'bold'
			// },
			// states: {
				// hover: {
					// fill: {
						// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
						// stops: [
							// [0.4, '#BBB'],
							// [0.6, '#888']
						// ]
					// },
					// stroke: '#000000',
					// style: {
						// color: 'white'
					// }
				// },
				// select: {
					// fill: {
						// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
						// stops: [
							// [0.1, '#000'],
							// [0.3, '#333']
						// ]
					// },
					// stroke: '#000000',
					// style: {
						// color: 'yellow'
					// }
				// }
			// }
		// },
		// inputStyle: {
			// backgroundColor: '#333',
			// color: 'silver'
		// },
		// labelStyle: {
			// color: 'silver'
		// }
	// },
// 
	// navigator: {
		// handles: {
			// backgroundColor: '#666',
			// borderColor: '#AAA'
		// },
		// outlineColor: '#CCC',
		// maskFill: 'rgba(16, 16, 16, 0.5)',
		// series: {
			// color: '#7798BF',
			// lineColor: '#A6C7ED'
		// }
	// },
// 
	// scrollbar: {
		// barBackgroundColor: {
				// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
				// stops: [
					// [0.4, '#888'],
					// [0.6, '#555']
				// ]
			// },
		// barBorderColor: '#CCC',
		// buttonArrowColor: '#CCC',
		// buttonBackgroundColor: {
				// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
				// stops: [
					// [0.4, '#888'],
					// [0.6, '#555']
				// ]
			// },
		// buttonBorderColor: '#CCC',
		// rifleColor: '#FFF',
		// trackBackgroundColor: {
			// linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
			// stops: [
				// [0, '#000'],
				// [1, '#333']
			// ]
		// },
		// trackBorderColor: '#666'
	// },
// 
	// // special colors for some of the demo examples
	// legendBackgroundColor: 'rgba(48, 48, 48, 0.8)',
	// legendBackgroundColorSolid: 'rgb(70, 70, 70)',
	// dataLabelsColor: '#444',
	// textColor: '#E0E0E0',
	// maskColor: 'rgba(255,255,255,0.3)'
// };
// 
// // Apply the theme
// var highchartsOptions = Highcharts.setOptions(Highcharts.theme);
