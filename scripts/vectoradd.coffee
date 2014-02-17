
class Matrix

  template: """
  <table class='matrix'><tr>
    <td class='leftBracket'></td>
    <td>
      <table>
        <tr><td>
          <span class="<% if (adjustable) { print('TKAdjustableNumber') } %> element" data-var="x" data-min="-5" data-max="5"></span>
        </td></tr>
        <tr><td>
          <span class="<% if (adjustable) { print('TKAdjustableNumber') } %> element" data-var="y" data-min="-5" data-max="5"></span>
        </td></tr>
      </table>
    </td>
    <td class='rightBracket'></td>
  </tr></table>
  """

  constructor: ($el, @x, @y) ->
    @$el = $el

  render: (options = {}) ->
    @$el.html _.template @template, adjustable:options.adjustable

    if options.adjustable
      # setup vector
      self = @
      model =
        initialize: () ->
            @x = self.x;
            @y = self.y;
        update: () ->
            self.$el.trigger 'change', @x, @y

      @tangle = new Tangle @$el[0], model

  set: (x, y) ->
    if @tangle
      @tangle.setValues x:x, y:y
    else
      @$el.find('[data-var="x"]').text(x)
      @$el.find('[data-var="y"]').text(y)
  get: (val) ->
    if @tangle
      @tangle.getValue(val)
    else
      @$el.find('[data-var="#{val}"]').text()



class VectorAdd 

  template: """
    <div class="container">
      <ul>
        <li class="matrix-container m1"></li>
        <li class="math">+</li>
        <li class="matrix-container m2"></li>
        <li class="math">=</li>
        <li class="matrix-container m3"></li>
      </ul>
      <div class='chart'></div>
      <div style='clear:both;'></div>
    </div>
  """

  render: (el) ->
    @$el = $(el)
    @$el.html(@template)

    matrix1 = new Matrix($(@$el.find('.matrix-container')[0]), 3, 4)
    matrix1.render( adjustable:true )
    matrix2 = new Matrix($(@$el.find('.matrix-container')[1]), 2, -3)
    matrix2.render( adjustable:true )
    matrix3 = new Matrix($(@$el.find('.matrix-container')[2]), 5, -1)
    matrix3.render()

    draw = () =>
      matrix3.set(matrix1.get('x')+matrix2.get('x'), matrix1.get('y')+matrix2.get('y'))
      @drawVectors(matrix1.get('x'), matrix1.get('y'), matrix2.get('x'), matrix2.get('y'))

    matrix1.$el.on "change", (x, y) -> draw()
    matrix2.$el.on "change", (x, y) -> draw()

    # setup chart
    @paper = Raphael @$el.find('.chart')[0], 300, 300
    draw()


  drawVectors: (x1, y1, x2, y2) ->
    @paper.clear()
    chart = @paper.chart([2,2], [298,298], [-10,10], [-10,10])

    #draw grid
    chart.attr = { "stroke": "#B5CBFF" }
    chart.addHorizontalLine(num, [-10, 10]) for num in [-10..10]
    chart.addVerticalLine(num, [-10, 10]) for num in [-10..10]
    chart.attr = { "stroke": "blue", "stroke-width":3, "arrow-end":"open", "opacity":0.5 }
    chart.addLine([0,0],[x1,y1])
    chart.attr = { "stroke": "red", "stroke-width":3, "arrow-end":"open", "opacity":0.5 }
    chart.addLine([x1+0.1,y1+0.1],[x1+x2+0.1,y1+y2+0.1])
    unless (x1+x2) is 0 and (y1+y2) is 0
      chart.attr = { "stroke": "green", "stroke-width":4, "arrow-end":"open", "opacity":0.8 }
      chart.addLine([0,0],[x1+x2,y1+y2])



# remove when loading class as module
window.VectorAdd = VectorAdd