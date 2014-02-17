class Sawtooth

  template: """
    <div class='chart'></div>
    <span class="TKAdjustableNumber number" data-var="n" data-min="1" data-max="99"></span>
    <div style="visibility:hidden;" class="equation">`\sum_(n=0)sin(nx)/n`</div>
    <div style="visibility:hidden;" class="nth-equation">`\y_n=sin(nx)/n`</div>
  """

  render: (el) ->
    @$el = $(el)
    @$el.html(@template)
    @equationEl = @$el.find('.equation')
    @nthEquationEl = @$el.find('.nth-equation')
    @paper = Raphael @$el.find('.chart')[0], 685, 200
    @makeItMath()

    self = @
    model =
      initialize: () ->
          @n = 1
      update: () ->
          self.draw(@n)
          n = if @n > 1 then @n else "n"
          self.nthEquationEl.text("`\y_"+n+"=sin("+n+"x)/"+n+"`")
          self.makeItMath()

    @tangle = new Tangle @$el[0], model
    @draw(1)


  draw: (n) ->

    func = (n, x) ->
      res = 0
      for nn in [n..1]
        res += Math.sin(nn*x)/nn
      return res

    @paper.clear()

    chart = @paper.chart([2,2], [683,200], [-2*Math.PI,2*Math.PI], [-2,2])

    chart.attr = "stroke":"#ccc", "stroke-width":"1"
    chart.addLine([-2*Math.PI, 0],[2*Math.PI, 0])
    chart.addLine([0, -1],[0, 1])
    chart.attr = "stroke":"#0969a2", "stroke-width":"4", "stroke-linecap":"round"
    chart.addFunction(((x)->func(n, x)), 0.02, [-2*Math.PI,2*Math.PI])
    if n > 1
      chart.attr = "stroke":"#008100", "stroke-opacity":0.1, "stroke-width":"4", "stroke-linecap":"round"
      chart.addFunction(((x)->func(n-1, x)), 0.02, [-2*Math.PI,2*Math.PI])

      chart.attr = "stroke":"#2a17b1", "stroke-opacity":0.1, "stroke-width":"4", "stroke-linecap":"round"
      chart.addFunction(((x)->Math.sin(n*x)/n), 0.02, [-2*Math.PI,2*Math.PI])

  # Works if you include MathJax on the page
  makeItMath: () ->
    # Pass @ in context because this Queue thing does funny things with context
    # TODO: fix the hack
    MathJax.Hub.Queue(["Typeset", MathJax.Hub, @$el[0]], ()=>@show(@) unless @shown)

  show: (self) ->
    self.equationEl.css("visibility","visible").hide().fadeIn()
    self.nthEquationEl.css("visibility","visible").hide().fadeIn()
    @shown = true



# remove when loading class as module
window.Sawtooth = Sawtooth