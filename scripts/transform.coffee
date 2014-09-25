
class MatrixTrans

  # Nest a table in a table to especially piss people off (or get something that looks
  # like a matrix, you decide)
  template: """
    <table class='matrix transformMatrix'><tr>
      <td class='leftBracket'></td>
      <td>
        <table>
          <tr>
            <td>
              <span class='TKAdjustableNumber'
                data-var='m11' data-min='-2' data-max='2' data-step='0.2'></span>
            </td>
            <td>
              <span class='TKAdjustableNumber'
                data-var='m12' data-min='-2' data-max='2' data-step='0.2'></span>
            </td>
          </tr>
          <tr>
            <td>
              <span class='TKAdjustableNumber'
                data-var='m21' data-min='-2' data-max='2' data-step='0.2'></span>
            </td>
            <td>
              <span class='TKAdjustableNumber'
                data-var='m22' data-min='-2' data-max='2' data-step='0.2'></span>
            </td>
          </tr>
        </table>
      </td>
      <td class='rightBracket'></td>
    </tr></table>
    <table class='matrix preVector'><tr>
      <td class='leftBracket'></td>
      <td>
        <table>
          <tr>
            <td>
              <span class='TKAdjustableNumber' data-var='x' data-min='-2' data-max='2'></span>
            </td>
          </tr>
          <tr>
            <td>
              <span class='TKAdjustableNumber' data-var='y' data-min='-2' data-max='2'></span>
            </td>
          </tr>
        </table>
      </td>
      <td class='rightBracket'></td>
    </tr></table>
    <span class='equalSign'>=</span>
    <table class='matrix preVector'><tr>
      <td class='leftBracket'></td>
      <td>
        <table>
          <tr>
            <td>
              <span class='xprime'></span>
            </td>
          </tr>
          <tr>
            <td>
              <span class='yprime'></span>
            </td>
          </tr>
        </table>
      </td>
      <td class='rightBracket'></td>
    </tr></table>
    <div class='chart1'></div>
    <div class='chart2'></div>
  """

  render: (el) ->
    @$el = $(el)
    @$el.html(@template)

    # setup charts
    @paper1 = Raphael @$el.find('.chart1')[0], 200, 200
    @paper2 = Raphael @$el.find('.chart2')[0], 200, 200

    # setup vector (Tangle has a very weird API)
    self = @
    model =
      initialize: () ->
          @m11 = 1; @m12 = 0; @m21 = 0; @m22 = 1;
          @x = 2;
          @y = 1;
      update: () ->
          self.updatePrime(@m11*@x+@m12*@y, @m21*@x+@m22*@y)
          self.drawVector(@x, @y, @m11, @m12, @m21, @m22)

    x = new Tangle @$el[0], model

  updatePrime: (xprime, yprime) ->
    @$el.find('.xprime').text(xprime.toFixed(2).replace(/\.?0+$/, ""))
    @$el.find('.yprime').text(yprime.toFixed(2).replace(/\.?0+$/, ""))

  drawVector: (x, y, m11, m12, m21, m22) ->
    @paper1.clear()
    @paper2.clear()
    chart1 = @paper1.chart([2,2], [198,198], [-5,5], [-5,5])
    chart2 = @paper2.chart([2,2], [198,198], [-5,5], [-5,5])

    drawNonTransform = (chart, opacity) ->
      # draw grid
      chart.attr = { "stroke": "#B5CBFF", "opacity": opacity}
      for num in [-5..5]
        chart.addHorizontalLine(num, [-5, 5])
        chart.addVerticalLine(num, [-5, 5])
      # draw vector
      chart.attr = { "stroke": "rgb(119, 110, 255)", "stroke-width":2, "arrow-end":"open", "opacity": opacity }
      chart.addLine([0,0],[x,y]) unless x is 0 and y is 0

    # draw non-transform for each chart
    drawNonTransform(chart1, 1)
    drawNonTransform(chart2, 0.5)

    # draw transformed grid
    chart2.attr = { "stroke": "red", "opacity": 0.3, "stroke-width":2}
    for num in [-5..5]
      chart2.addLine [m11*num+m12*(-5), m21*num+m22*(-5)],
                    [m11*num+m12*(5), m21*num+m22*(5)]
      chart2.addLine [m11*(-5)+m12*num, m21*(-5)+m22*num],
                    [m11*(5)+m12*num, m21*(5)+m22*num]
    # draw non-transform vector
    chart2.attr = { "stroke": "red", "stroke-width":3, "arrow-end":"open" }
    chart2.addLine([0,0],[m11*x+m12*y, m21*x+m22*y]) unless x is 0 and y is 0

# remove when loading class as module
window.MatrixTrans = MatrixTrans
