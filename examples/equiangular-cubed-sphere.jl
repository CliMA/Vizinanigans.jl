using Makie, GLMakie, GeometryBasics

function cubedshellwarp(a, b, c, R = max(abs(a), abs(b), abs(c)))

    function f(sR, ξ, η)
        X, Y = tan(π * ξ / 4), tan(π * η / 4)
        x1 = sR / sqrt(X^2 + Y^2 + 1)
        x2, x3 = X * x1, Y * x1
        x1, x2, x3
    end

    fdim = argmax(abs.((a, b, c)))
    if fdim == 1 && a < 0
        # (-R, *, *) : Face I from Ronchi, Iacono, Paolucci (1996)
        x1, x2, x3 = f(-R, b / a, c / a)
    elseif fdim == 2 && b < 0
        # ( *,-R, *) : Face II from Ronchi, Iacono, Paolucci (1996)
        x2, x1, x3 = f(-R, a / b, c / b)
    elseif fdim == 1 && a > 0
        # ( R, *, *) : Face III from Ronchi, Iacono, Paolucci (1996)
        x1, x2, x3 = f(R, b / a, c / a)
    elseif fdim == 2 && b > 0
        # ( *, R, *) : Face IV from Ronchi, Iacono, Paolucci (1996)
        x2, x1, x3 = f(R, a / b, c / b)
    elseif fdim == 3 && c > 0
        # ( *, *, R) : Face V from Ronchi, Iacono, Paolucci (1996)
        x3, x2, x1 = f(R, b / c, a / c)
    elseif fdim == 3 && c < 0
        # ( *, *,-R) : Face VI from Ronchi, Iacono, Paolucci (1996)
        x3, x2, x1 = f(-R, b / c, a / c)
    else
        error("invalid case for cubedshellwarp: $a, $b, $c")
    end

    return x1, x2, x3
end

n = 20

r = range(-1,1,length=n+1)

xa = zeros(n+1,n+1)
xb = zeros(n+1,n+1)
xc = zeros(n+1,n+1)

xa .= r
xb .= r'
xc .= 1

a = [cubedshellwarp(a,b,c)[1] for (a,b,c) in zip(xa,xb,xc)]
b = [cubedshellwarp(a,b,c)[2] for (a,b,c) in zip(xa,xb,xc)]
c = [cubedshellwarp(a,b,c)[3] for (a,b,c) in zip(xa,xb,xc)]


sc = Scene(limits = HyperRectangle(Vec3f0(-2), Vec3f0(2)))

wireframe!(sc,
           a,b,c,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           a,b,-c,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           c,a,b,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           -c,a,b,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           b,c,a,
           show_axis=false,
           linewidth=1.2)
wireframe!(sc,
           b,-c,a,
           show_axis=false,
           linewidth=1.2)

sc
