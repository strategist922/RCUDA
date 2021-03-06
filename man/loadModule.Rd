\name{loadModule}
\alias{loadModule}
\alias{getFunction}

\alias{$,CUmodule-method}
\alias{[[,CUmodule,character,missing-method}

\title{Load a GPU module and access its Routines}
\description{
  These functions load a module and allow us to get a reference
  to any of the named functions/routines or global variables it contains.
}
\usage{
loadModule(filename, ctx = cuGetContext(TRUE),
           isCode = is(filename, "raw") || is(filename, "AsIs") || grepl(" __cudaparm", filename),  
           ...)
getFunction(module, name) 
\S4method{$}{CUmodule}(x, name)
\S4method{[[}{CUmodule,character,missing}(x, i,j, globalVar = FALSE, ...)
}

\arguments{
  \item{filename}{the name of the file containing the GPU module. This
    can be in PTX, cubin or fatbin format. It is important that the code
    be compiled correctly for the appropriate architecture/GPU device.
    If not, an error is raised.}
  \item{ctx}{the context into which to load the module. If none has been
  created, this creates  default contet that is used for this and
  subsequent computations.}
\item{isCode}{a logical value that indicates whether \code{filename} is actually the  PTX
   code itself or the name of a file containing the code. This allows us to 
   obtain the code in R as a string and load it directly.
 One can use this argument or alternatively wrap the PTX text
  within a call to \code{I()} to indicate that it is the PTX code and not the name of a
  file. We also use some heuristic to determine if the text is PTX code.
  } 
 \item{\dots}{additional parameters for methods}
 \item{module,x}{the module object returned by \code{loadModule} in which
  we will find the named function}
\item{name,i}{the name of the function to find in the module.
   It is imperative that the kernel we want be compiled with the
   declaration \code{extern "C"} so that its name is not mangled.}
\item{j}{missing/not supplied}
 \item{globalVar}{a logical that controls whether we are looking for a variable or a routine/function in the module.}
}
\value{
  \code{loadModule} returns an reference to the C object
  and is of class \code{CUmodule} in R.

  \code{getFunction}, if it succeeds, returns an object of class
  \code{CUfunction}   and is a reference to the C data type representing
  this routine.
}
\references{
\url{http://docs.nvidia.com/cuda/cuda-driver-api/index.html#group__CUDA__MODULE}
}
\author{Duncan Temple Lang}

\seealso{
\code{\link{.cuda}}
}
\examples{
if(getNumDevices() > 0) {
  ctx = cuGetContext(TRUE)
  ptx = system.file("sampleKernels", "dnormOutput.ptx", package = "RCUDA")
  m = loadModule(ptx)
  kernel = m$dnorm_kernel
}
}
\keyword{programming}
\concept{parallel}
\concept{GPU}
