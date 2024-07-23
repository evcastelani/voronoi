
using Plots 
struct Point2D
	x::Float64
	y::Float64 
end

# geração de pontos no plano
function generate_points(n::Int;limit=[0,100])
	x = rand([limit[1]:1:limit[2];],n)
	y = rand([limit[1]:1:limit[2];],n)
	v = Vector{Point2D}(undef,n)
	for i=1:n
		v[i] = Point2D(x[i],y[i])
	end 
	return v
end

# plotando os pontos 


function draw_points(v::Vector{Point2D},plt::Plots.Plot)
	x = [v[i].x for i=1:length(v)]
	y = [v[i].y for i=1:length(v)]
	scatter!(plt,x,y,color="black",markersize=3,legend=false)
end 

function draw_border(v::Vector{Point2D},plt::Plots.Plot)
	x = [v[i].x for i=1:length(v)]
	y = [v[i].y for i=1:length(v)]
	scatter!(plt,x,y,color="black",markersize=1,legend=false)
end 

function draw_colored_points(v::Vector{Point2D},labels::Vector{Int64},plt::Plots.Plot)
	x = [v[i].x for i=1:length(v)]
	y = [v[i].y for i=1:length(v)]
	scatter!(plt,x, y, c=labels, colors=:hot,m=Plots.stroke(0),markersize=1,legend=false)
end

""" Exemplo de uso 
julia> v = generate_points(10)

julia> voronoi(v,(A::Point2D,B::Point2D)->abs(B.x-A.x)+abs(B.y-A.y);density=2000)

julia> voronoi(v;density=2000)

Obs. Notei que a densidade deve ser alta para termos um resultados razóavel ao pintar as bordas. 
"""
function voronoi(P::Vector{Point2D},metric=(A::Point2D,B::Point2D)->sqrt((B.x-A.x)^2+(B.y-A.y)^2);limx=[0,100],limy=[0,100],density=1000)
	px = [limx[1]:(limx[2]-limx[1])/density:limx[2];]
	py = [limx[1]:(limy[2]-limy[1])/density:limy[2];]
	npx = length(px)
	npy = length(py)
	n = length(P)
	points = Point2D[]
	border = Point2D[]
	labels = Int64[]
	for i=1:npx 
		for j=1:npy 
			minval = metric(P[1],Point2D(px[i],py[j]))
			secval = 0.0
			imin = 1
			for k=2:n 
				if minval>metric(P[k],Point2D(px[i],py[j]))
					secval = minval 
					minval = metric(P[k],Point2D(px[i],py[j]))
					imin = k 
				end
			end
			if abs(secval - minval)/density<1.0e-4
				push!(border, Point2D(px[i],py[j]))
				#println("$(secval) - $(minval)")
			end 
			push!(points,Point2D(px[i],py[j]))
			push!(labels,imin)
			
		end
		
	end
	plt = plot()
	println("Drawing ... ")
	draw_colored_points(points,labels,plt)
	draw_border(border,plt) 
	draw_points(P,plt) 
end
