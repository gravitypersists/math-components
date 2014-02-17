
class Vector

  template: """
    <table class='matrix'><tr>
      <td class='leftBracket'></td>
      <td>
        <table>
          <tr><td>
            <span class="TKAdjustableNumber" data-var="x" data-min="-5" data-max="5"></span>
          </td></tr>
          <tr><td>
            <span class="TKAdjustableNumber" data-var="y" data-min="-5" data-max="5"></span>
          </td></tr>
        </table>
      </td>
      <td class='rightBracket'></td>
    </tr></table>
    <div class='chart'></div>
  """

  render: (el) ->
    @$el = $(el)
    @$el.html(@template)

    # setup chart
    @paper = Raphael @$el.find('.chart')[0], 200, 200

    # setup vector
    self = @
    model =
      initialize: () ->
          @x = 2;
          @y = 4;
      update: () ->
          self.drawVector(@x,@y)

    new Tangle @$el[0], model


  drawVector: (x, y) ->
    @paper.clear()
    chart = @paper.chart([2,2], [198,198], [-5,5], [-5,5])

    #draw grid
    chart.attr = { "stroke": "#B5CBFF", "opacity": 0.2}
    chart.addHorizontalLine(num, [-5, 5]) for num in [-5..5]
    chart.addVerticalLine(num, [-5, 5]) for num in [-5..5]
    chart.attr = { "stroke": "#B5CBFF" }
    chart.addHorizontalLine(num, [Math.min(0,x), Math.max(0,x)]) for num in [0..y]
    chart.addVerticalLine(num, [Math.min(0,y), Math.max(0,y)]) for num in [0..x]
    chart.attr = { "stroke": "green", "stroke-width":3, "arrow-end":"open" }
    chart.addLine([0,0],[x,y]) unless x is 0 and y is 0


# remove when loading class as module
window.Vector = Vector 
