using Plots
input(str_out::String) = begin
    print(str_out)
    return readline()
end

sin_gen(xs,f) = sin.(xs*f)
sin_gen(xs,f,constant) = 1/constant*sin.(constant*xs*f)
square_gen(xs,n_harmonics) = begin 
    f = 1
    vec_aux = sin_gen(xs,f,1)
    for x in 1:n_harmonics-1
        vec_aux = vec_aux + sin_gen(xs,f,x*2 + 1)
    end
    return 4/pi*vec_aux
end



data_dict= Dict(
    "sin" => sin_gen,
    "square" => square_gen
)
# 10 data points in 4 series
data(xs,f) = 4/pi*(cos.(xs*f) + 1/3*cos.(3*xs*f) + 1/5*cos.(5*xs*f) + 1/7*cos.(7*xs*f))

# We put labels in a row vector: applies to each series
labels = ["Amostra" "Ideal"]

# Marker shapes in a column vector: applies to data points
markershapes = [:circle :none]

# Marker colors in a matrix: applies to series and data points
markercolors = [
    :blue :green
]

save_plot(f_harmonics, n_samples=10; signal_choice::String) = begin
    xs = range(0, 2π, length = trunc(Int,n_samples))
    if signal_choice == "square"
        int_aux = 50*(2*(f_harmonics-1) + 1)
    else
        int_aux = f_harmonics*50
    end
    xs_ideal = range(0, 2π, length = trunc(Int,int_aux))
    savefig(plot(
        [xs, xs_ideal],
        [data_dict[signal_choice](xs,f_harmonics), data_dict[signal_choice](xs_ideal,f_harmonics)],
        label = labels,
        shape = markershapes,
        color = markercolors,
        markersize = 5
    ), "plot_fig.png")
end
# while true
#     aux = input("\nPress enter to finish\n")
#     print("A entrada foi: $aux")
#     break
# end


