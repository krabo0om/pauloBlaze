library(plotrix)
data <- data.frame(Slices=c(1266, 1242,1348), Registers=c(2924,2925,2928), LUTs=c(2420,2404,2599), LUTRAMs=c(774,774,781))
colors = c("#22AD36", "#7EC67F", "#9cb1db")
pdf("res_sofpga.pdf", width=9, height=5)
par(mar=par()$mar+c(2.0, 0, 0, 0), xpd=TRUE)
barp(data, names.arg=names(data),  col=colors, main="Resource Usage SoFPGA", xlab="Category", ylab="Usage Number")

legend(1, -1100, c("Pico constrained", "Pico unconstrained", "PauloBlaze"), col=colors, fill=colors, ncol=3)#, pch=c(1,3), lty=c(1,3))

dev.off()
