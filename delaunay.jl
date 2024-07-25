# definição da estrutura de pontos planos 
mutable struct Point2D
    x::Float64 
    y::Float64 
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

function draw_edges(w::Vector{Edge})
    for i=1:length(w)
        plot([w[i].A.x,w[i].B.x],[w[i].A.y,w[i].B.y],color="red")
:    end
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
    return 1-((u'*v)/(norm(u,2)*norm(v,2)))
end 

function pseudo_angle(P::Point2D,R::Point2D,Q::Point2D)
    u = [P.x-R.x,P.y-R.y]
    v = [Q.x-R.x,Q.y-R.y]
    return 1-((u'*v)/(norm(u,2)*norm(v,2)))
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
    # neste ponto, determinamos a primeira aresta que é uma aresta do fecho convexo. 
    # Iremos exemplorar essa as arestas subsequentes. Para isso, vamos criar uma estrutura que armazena 
    # os triângulos e uma estrutura que armazena as arestas. O algoritmo irá parar quando não tivermos 
    # mais arestas para explorar. 
    edgeset = Edge[]
    push!(edgeset,currentedge)
    countedge = 1
    triangleset = Triangle[]
    while countedge <= length(edgeset)
        currentedge = edgeset[countedge]
        θleft = 0.0
        iminleft = 0 
        θleftmax = 0.0
        θright = 0.0
        θrightmax = 0.0
        iminright = 0 
        for i=1:n
            valueside = side(currentedge,v[i])
            println("valueside = $(valueside)")
            if valueside>0.0  # ponto a esquerda
                θleft = pseudo_angle(currentedge.A,v[i],currentedge.B)
                println("θleft = $(θleft)")
                if θleft>θleftmax 
                    θleftmax = θleft 
                    iminleft = i 
                end
            elseif valueside<0.0 # ponto a direita
                θright = pseudo_angle(currentedge.A,v[i],currentedge.B)
                println("θright = $(θright)")
                if θright>θrightmax 
                    θrightmax = θright 
                    iminright = i 
                end
                
            end
        end 
        if iminleft > 0 
            # display(Triangle(currentedge.A,currentedge.B,v[iminleft]))
            candidate_edge1 = Edge(currentedge.A,v[iminleft])
            candidate_edge2 = Edge(v[iminleft],currentedge.A)
            isnewpoint = false 
            if candidate_edge1 ∉ edgeset && candidate_edge2 ∉ edgeset
                push!(edgeset,candidate_edge1)
                isnewpoint =true 
            end
            candidate_edge1 = Edge(currentedge.B,v[iminleft])
            candidate_edge2 = Edge(v[iminleft],currentedge.B)
            if candidate_edge1 ∉ edgeset && candidate_edge2 ∉ edgeset
                push!(edgeset,candidate_edge1)
                isnewpoint = true 
            end
            if isnewpoint
                push!(triangleset,Triangle(currentedge.A,currentedge.B,v[iminleft]))
            end
        end
        if iminright > 0 
            #display(Triangle(currentedge.A,currentedge.B,v[iminright]))
            candidate_edge1 = Edge(currentedge.A,v[iminright])
            candidate_edge2 = Edge(v[iminright],currentedge.A)
            isnewpoint = false 
            if candidate_edge1 ∉ edgeset && candidate_edge2 ∉ edgeset
                push!(edgeset,candidate_edge1)
                isnewpoint = true  
            end
            candidate_edge1 = Edge(currentedge.B,v[iminright])
            candidate_edge2 = Edge(v[iminright],currentedge.B)
            if candidate_edge1 ∉ edgeset && candidate_edge2 ∉ edgeset
                push!(edgeset,candidate_edge1)
                isnewpoint = true 
            end
            if isnewpoint
                push!(triangleset,Triangle(currentedge.A,currentedge.B,v[iminright]))
            end
        end
        println("edgeset = ")
        display(edgeset)
        println("currentedge = $(currentedge)")
        println("countedge = $(countedge), iminright=$(iminright),iminleft = $(iminleft)")
        countedge += 1
    end
    return edgeset, triangleset
end

struct VoronoiPolygon
    vertices::Vector{Point2D}    
end

function circumcenter(T::Triangle)
    u = Point2D(T.P2.x-T.P1.x,T.P2.y-T.P1.y)
    v = Point2D(T.P3.x-T.P1.x,T.P3.y-T.P1.y)
    m1 = Point2D(T.P1.x+0.5*u.x,T.P1.y+0.5*u.y)
    m2 = Point2D(T.P1.x+0.5*v.x,T.P1.y+0.5*v.y)
    u = Point2D(u.y,-u.x)
    v = Point2D(v.y,-v.x)
    A = [u.x -v.x;u.y -v.y]
    b = [m2.x-m1.x,m2.y-m1.y]
    display(det(A))
    s = A\b
    return Point2D(m1.x+s[1]*u.x,m1.y+s[1]*u.y)
end 

function voronoi(v::Vector{Point2D},T::Vector{Triangle})
    n = length(v)
    # determinamos os triangulos que tem vértice comum
    foundtriangle = Vector{Vector{Int}}(undef,n)
    for i=1:n
        foundtriangle[i] = Int64[]
        for k = 1:length(T)
            if v[i] in [T[k].P1,T[k].P2,T[k].P3]
                push!(foundtriangle[i],k)
            end
        end

    end 
    display(foundtriangle)
    # calculamos os circuncentros 
    s = Vector{Point2D}(undef,length(T))
    for i=1:length(T) 
        s[i] = circumcenter(T[i])
    end
    return s
    # ordenamos radialmente
    
    # retornamos o poligono de voronoi  
    
end
