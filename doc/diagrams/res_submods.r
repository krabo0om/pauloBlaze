library(plotrix)
data <- data.frame(Slices=c(i57, 33, 100), SliceRegisters=c(79,79,83), LUTs=c(108,129,155), LUTRAM=c(49,49,56))
pdf("res_submod.pdf", width = 10, height=7)
colors = c("#6DBF6F", "#199367", "#2F4067")
par(mar=par()$mar+c(0, 0, 0, 10), xpd=TRUE)
barp(data, names.arg=names(data), col=colors, main="Resource Usage P*Blaze", xlab="Category", ylab="Usage Number")

legend(4.8, 80, c("Pico constrained", "Pico unconstrained", "PauloBlaze"), col=colors, fill=colors)

dev.off()
