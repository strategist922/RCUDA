# When working, also examine
# using cudaMallocPitch()
# and passing the two matrices separately to the euclidean_kernel routine 

library(RCUDA)
mod = loadModule("distance_gputools.ptx")

N = c(A = 1000L, B = 999L)
p = 70L

if(TRUE) {
 N = c(A = 2L, B = 3L)
 p = 2L
}

if(TRUE) {
 A = matrix(rnorm(N["A"]*p), N["A"], p)
 B = matrix(rnorm(N["B"]*p), N["B"], p)
} else {
 A = matrix(as.numeric(1:(N["A"]*p)), N["A"], p)
 B = matrix(as.numeric(1:(N["B"]*p)), N["B"], p)
}

if(FALSE) {
AB = rbind(A, B)
ABref = copyToDevice(t(AB), elType = "float")
ans = cudaMalloc(sum(N)^2, elType = "float")
.gpu(mod$euclidean_kernel_same,
     ABref, p, sum(N),
     ABref, p, sum(N),
     p, ans, sum(N), 2.0,
     outputs = FALSE, gridDim = c(nrow(AB), nrow(AB)), blockDim = 32L)
out = copyFromDevice(ans, sum(N)^2, "float")
d.AB = matrix(out, sum(N), sum(N))
}

if(FALSE) {
  # Desired way to do this.
AB = rbind(A, B)
kernel = mod$euclidean_kernel_same
  # Don't want two copies.
ABref = copyToDevice(t(AB)) 
out = .gpu(kernel,
              ABref, p, sum(N),
              ABref, p, sum(N),  # in fact these arguments are never used.
              p, ans = numeric(sum(N)^2), sum(N), 2.0,
              outputs = "ans", gridDim = c(nrow(AB), nrow(AB)), blockDim = 32L)
d.AB = matrix(out, sum(N), sum(N))
d.AB - as.matrix(dist(AB))
print(max(abs(d.AB - as.matrix(dist(AB)))))
}


if(FALSE) {
  # Desired way to do this.
AB = rbind(A, B)
tm = system.time({
out = .gpu(mod$euclidean_kernel_same,
              t(AB), ncol(AB), nrow(AB),
              NULL, 0L, 0L, 
              ncol(AB), ans = numeric(nrow(AB)^2), nrow(AB), 2.0,
              outputs = "ans", gridDim = c(nrow(AB), nrow(AB)), blockDim = 32L)
d.AB = matrix(out, sum(N), sum(N))
})
d.AB - as.matrix(dist(AB))
print(max(abs(d.AB - as.matrix(dist(AB)))))
}


if(FALSE) {
# This is the version that uses the two input kernel
# and avoids stacking the  matrices in R.
k = mod$euclidean_kernel
gdist = function(A, B) { 
    out = .gpu(k, t(A), ncol(A), nrow(A), 
                  t(B), ncol(A), nrow(B), 
                  ncol(A), ans = numeric(nrow(A)*nrow(B)), nrow(A), 2.0,
                 outputs = "ans", gridDim = c(nrow(A), nrow(B)), blockDim = 32L)
     DD = matrix(out, nrow(A), nrow(B))
}
system.time({DD = gdist(A, B)})
print(max(abs(DD - as.matrix(dist(AB))[1:nrow(A), - (1:nrow(A))])))
}



