class SinWave

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
      <span class="TKAdjustableNumber" data-var="A" data-min="-1" data-max="1" data-step="0.01" data-scale="2"></span>
      <em>sin </em>(
      <span class="TKAdjustableNumber" data-var="w" data-min="-6.28" data-max="6.28" data-step="0.01" data-scale="2"></span>
      <em>x</em> +
      <span class="TKAdjustableNumber" data-var="B" data-min="-6.28" data-max="6.28" data-step="0.01" data-scale="2"></span>
      )
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
          @A = 1
          @w = 1
          @B = 0
      update: () ->
          self.draw(@A, @w, @B)

    @tangle = new Tangle @$el[0], model

    chart = @paperbg.chart([2,2], [723,200], [-2*Math.PI-0.4,2*Math.PI+0.4], [-1,1])
    chart.attr = "stroke":"#ccc", "stroke-width":"1"
    chart.addLine([-2*Math.PI, 0],[2*Math.PI, 0])
    chart.addLine([0, -1],[0, 1])
    axis = chart.addHorizontalAxis([-2*Math.PI,2*Math.PI], 0, {drawLine:false})
    (axis.addTick(i*Math.PI/2, 5).attr("stroke":"#ccc", "stroke-width":"1") if i) for i in [-4..4]
    axis.addLabel(-2*Math.PI, "-2\u03C0").addClass('x-labels')
    axis.addLabel(-1*Math.PI, "-\u03C0").addClass('x-labels')
    axis.addLabel(1*Math.PI, "\u03C0").addClass('x-labels')
    axis.addLabel(2*Math.PI, "2\u03C0").addClass('x-labels')

    @draw(1, 1, 0)


  draw: (A, w, B) ->
    @paper.clear()
    chart = @paper.chart([2,2], [723,200], [-2*Math.PI-0.4,2*Math.PI+0.4], [-1,1])
    chart.attr = "stroke":"blue", "stroke-width":"3", "stroke-linecap":"round"
    chart.addFunction(((x) -> A*Math.sin(w*x+B)), 0.02, [-2*Math.PI,2*Math.PI])



# remove when loading class as module
window.SinWave = SinWave
