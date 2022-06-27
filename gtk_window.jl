using Gtk, Graphics
using Cairo

include("plots_julia.jl")
int(value) = trunc(Int, value)

run_tag = true

function drawSys(widget)
    ctx = Gtk.getgc(widget)
    
    c = CairoRGBSurface(400,20);
    cr = CairoContext(c);

    set_source_rgb(cr,0.8,0.8,0.8);    # light gray
    rectangle(cr,0.0,0.0,800.0,650.0); # background
    fill(cr);

    image = read_from_png("plot_fig.png")
    
    set_source_surface(ctx, image, 0, 0)
    paint(ctx)
end

function build_label(label_name, label_text, label_justify)
    justify_dict = Dict(
        "left"=>Gtk.GConstants.GtkJustification.LEFT,
        "rigth"=>Gtk.GConstants.GtkJustification.RIGHT,
        "center"=>Gtk.GConstants.GtkJustification.CENTER
    )
    new_label = GtkLabel(label_name)
    GAccessor.markup(new_label,label_text)
    GAccessor.selectable(new_label,true)
    GAccessor.justify(new_label,justify_dict[label_justify])
    return new_label
end


function build_window_4()
    win = GtkWindow("Gtk signal manipulation")
    

    canvas = Gtk.Canvas(600, 400)
    canvas.draw = drawSys
    b = GtkButton("Atualizar")
    n_samples = GtkScale(false, 4:30)
    freq = GtkScale(false, 2:30)

    cb = GtkComboBoxText()
    for item in collect(keys(data_dict))
        push!(cb,item)
    end
    set_gtk_property!(cb,:active,0)
    get_cb_string(combo_box)=Gtk.bytestring(GAccessor.active_text(combo_box))
    get_cb_string()=get_cb_string(cb)

    first_label = build_label("first_label", "Número de amostras", "left")
    second_label_text_dict = Dict(
        "sin" => "Frequência do sinal",
        "square" => "Número de harmônicos do sinal"
    )
    second_label = build_label("second_label", second_label_text_dict[get_cb_string()], "left")
    
    g = GtkGrid()
    g[1,1] = cb
    g[1,2] = first_label
    g[1,3] = n_samples
    g[1,4] = second_label
    g[1,5] = freq
    g[1,6] = canvas
    # set_gtk_property!(g, :column_homogeneous, true)
    push!(win, g)

    signal_connect(cb, "changed") do widget, others...
        update_plot_figure()
        GAccessor.markup(second_label,second_label_text_dict[get_cb_string()])

    end

    signal_connect(freq, "value-changed") do widget, others...
        update_plot_figure()
    end

    signal_connect(n_samples, "value-changed") do widget, others...
        update_plot_figure()
    end

    update_plot_figure(freq,samples)=begin
        save_plot(freq,samples; signal_choice = get_cb_string())
        draw(canvas)
    end
    update_plot_figure()= update_plot_figure(GAccessor.value(freq),GAccessor.value(n_samples))
    update_plot_figure()
    
    return win
end

window_dict = Dict(
  "name"=>"Janela 4",
  "function"=>build_window_4
)

if run_tag
    win = build_window_4()
    showall(win)
    c = Condition()
    signal_connect(win, :destroy) do widget
        notify(c)
    end
    wait(c)
  
  end