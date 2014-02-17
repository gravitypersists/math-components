class Superposition

  template: """
    <div class='top equation'>
      <em>y = <span class='emphasized'>A</span> sin</em> ( <em><span class='emphasized'>&omega;</span> x + <span class='emphasized'>&phi;</span></em> )
    </div>
    <div>
      <div class='chart-bg'></div>
      <div class='chart'></div>
    </div>
    <div class='bottom equation'>
      <em>y =</em>
      <span class="first-equation">
        <span class="TKAdjustableNumber" data-var="A1" data-min="-1" data-max="1" data-step="0.01" data-scale="2"></span>
        <em>sin</em>(
        <span class="TKAdjustableNumber" data-var="w1" data-min="-6.28" data-max="6.28" data-step="0.01" data-scale="2"></span>
        <em>x</em> +
        <span class="TKAdjustableNumber" data-var="B1" data-min="-6.28" data-max="6.28" data-step="0.01" data-scale="2"></span>
        )
      </span>
      +
      <span class="second-equation">
        <span class="TKAdjustableNumber" data-var="A2" data-min="-1" data-max="1" data-step="0.01" data-scale="2"></span>
        <em>sin</em>(
        <span class="TKAdjustableNumber" data-var="w2" data-min="-6.28" data-max="6.28" data-step="0.01" data-scale="2"></span>
        <em>x</em> +
        <span class="TKAdjustableNumber" data-var="B2" data-min="-6.28" data-max="6.28" data-step="0.01" data-scale="2"></span>
        )
      </span>
    </div>
  """

  render: (el) ->
    @$el = $(el)
    @$el.html(@template)
    @paperbg = Raphael @$el.find('.chart-bg')[0], 725, 210
    @paper = Raphael @$el.find('.chart')[0], 725, 210

    self = @
    model =
      initialize: () ->
          @A1 = 1
          @w1 = 1
          @B1 = 0
          @A2 = 0.7
          @w2 = 1
          @B2 = 3.14
      update: () ->
          self.draw(@A1, @w1, @B1, @A2, @w2, @B2)

    @tangle = new Tangle @$el[0], model

    chart = @paperbg.chart([2,2], [723,200], [-2*Math.PI-0.4,2*Math.PI+0.4], [-1,1])
    chart.attr = "stroke":"#ccc", "stroke-width":"1"
    chart.addLine([-2*Math.PI, 0],[2*Math.PI, 0])
    chart.addLine([0, -1],[0, 1])
    axis = chart.addHorizontalAxis([-2*Math.PI,2*Math.PI], 0, {drawLine:false})
    (axis.addTick(i*Math.PI/2, 5).attr("stroke":"#ccc") if i) for i in [-4..4]
    axis.addLabel(-2*Math.PI, "-2\u03C0").addClass('x-labels')
    axis.addLabel(-1*Math.PI, "-\u03C0").addClass('x-labels')
    axis.addLabel(1*Math.PI, "\u03C0").addClass('x-labels')
    axis.addLabel(2*Math.PI, "2\u03C0").addClass('x-labels')

    @draw(1, 1, 0, 0.7, 1, 3.14)


  draw: (A1, w1, B1, A2, w2, B2) ->
    @paper.clear()

    chart = @paper.chart([2,2], [723,200], [-2*Math.PI-0.4,2*Math.PI+0.4], [-2,2])

    chart.attr = "stroke":"#ccc", "stroke-width":"1"
    chart.addLine([-2*Math.PI, 0],[2*Math.PI, 0])
    chart.addLine([0, -1],[0, 1])
    chart.attr = "stroke":"rgba(200, 0, 255, 1)", "stroke-width":"4", "stroke-linecap":"round"
    chart.addFunction(((x) -> A1*Math.sin(w1*x+B1)+A2*Math.sin(w2*x+B2)), 0.02, [-2*Math.PI,2*Math.PI])
    chart.attr = "stroke":"#aa0000", "stroke-width":"3", "stroke-linecap":"round", "opacity": 0.1
    chart.addFunction(((x) -> A2*Math.sin(w2*x+B2)), 0.02, [-2*Math.PI,2*Math.PI])
    chart.attr = "stroke":"#0000ff", "stroke-width":"3", "stroke-linecap":"round", "opacity": 0.1
    chart.addFunction(((x) -> A1*Math.sin(w1*x+B1)), 0.02, [-2*Math.PI,2*Math.PI])


window.Superposition = Superposition
