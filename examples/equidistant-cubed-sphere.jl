using Makie, GLMakie, GeometryBasics

function equidistant_cubed_shell_warp(a, b, c, R = max(abs(a), abs(b), abs(c)))

    r = hypot(a, b, c)

    x1 = R * a / r
    x2 = R * b / r
    x3 = R * c / r

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

a = [equidistant_cubed_shell_warp(a,b,c)[1] for (a,b,c) in zip(xa,xb,xc)]
b = [equidistant_cubed_shell_warp(a,b,c)[2] for (a,b,c) in zip(xa,xb,xc)]
c = [equidistant_cubed_shell_warp(a,b,c)[3] for (a,b,c) in zip(xa,xb,xc)]


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
