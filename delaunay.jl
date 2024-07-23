# definição da estrutura de pontos planos 
struct Point2D
    x::Int64 
    y::Int64 
end

struct Edge
    A::Point2D
    B::Point2D 
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
struct Triangle
   P1::Point2D
   P2::Point2D
   P3::Point2D 
end
# plotando os pontos 
using PyPlot

function draw_points(v::Vector{Point2D})
    x = [v[i].x for i=1:length(v)]
    y = [v[i].y for i=1:length(v)]
    scatter(x,y)
end

function draw_edges(w::Edge)
    plot([w.A.x,w.B.x],[w.A.y,w.B.y],color="red")
end

function draw_triangle(T::Triangle)
    plot([T.P1.x,T.P2.x],[T.P1.y,T.P2.y],color="red") 
    plot([T.P2.x,T.P3.x],[T.P2.y,T.P3.y],color="red")
    plot([T.P3.x,T.P1.x],[T.P3.y,T.P1.y],color="red")
end 

using LinearAlgebra

function side(W::Edge,P::Point2D)
    return (W.B.x-W.A.x)*(P.y-W.A.y)-(W.B.y-W.A.y)*(P.x-W.A.x)
end

function pseudo_angle(W::Edge,P::Point2D)
    u = [W.B.x-W.A.x,W.B.y-W.A.y]
    v = [P.x-W.A.x,P.y-W.A.y]
    return (1-u'*v)/(norm(u,2)*norm(v,2))
end 

function pseudo_angle(P::Point2D,R::Point2D,Q::Point2D)
    u = [P.x-R.x,P.y-R.y]
    v = [Q.x-R.x,Q.y-R.y]
    return (1-u'*v)/(norm(u,2)*norm(v,2))
end

function delaunay(v::Vector{Point2D})
    # inicialização
    w = Vector{Edge}[]
    # vamos determinar uma aresta do fecho convexo 
    n = length(v)
    min = v[1].y 
    imin = 1 
    for i=2:n
        if min>v[i].y 
            imin = i
            min = v[i].y 
        end
    end
    P = v[imin]
    currentedge = Edge(P,Point2D(P.x+1,P.y))
    imin = 1 
    θmin = pseudo_angle(currentedge,v[imin])
    while abs(θmin)<1.0e-8
        imin += 1
        θmin = pseudo_angle(currentedge,v[imin])
    end
    for i=2:n
        θ = pseudo_angle(currentedge,v[i])
        if θmin > θ && abs(θ)>1.0e-10
            θmin = θ
            imin = i 
        end 
    end
    Q = v[imin] 
    currentedge = Edge(P,Q)

    θleft = 0.0
    iminleft = 0 
    θleftmax = 0.0
    θright = 0.0
    θrightmax = 0.0
    iminright = 0 
    for i=1:n
        valueside = side(currentedge,v[i])>0.0 
        if valueside>1.0e-8  # ponto a esquerda
            θleft = pseudo_angle(currentedge.A,v[i],currentedge.B)
            if θleft>θleftmax 
                θleftmax = θleft 
                iminleft = i 
            end
        elseif valueside<-1.0e-8 # ponto a direita
            θright = pseudo_angle(currentedge.A,v[i],currentedge.B)
            if θright>θrightmax 
                θrightmax = θright 
                iminright = i 
            end

        end
    end 
    if iminleft > 0 
        display(Triangle(currentedge.A,currentedge.B,v[iminleft]))
    end
    if iminright > 0 
        display(Triangle(currentedge.A,currentedge.B,v[iminright]))
    end
end
