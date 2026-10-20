// Lucide placeholder icon paths (24×24 viewBox).
// Source: Lucide Icons (ISC) via path geometry; swap this pack for hand-drawn SVGs later.
// See Design/Icons/Lucide/*.svg for the original SVG files.
import SwiftUI

enum LucidePlaceholderPaths {
    static let viewBox: CGFloat = 24

    static func path(for icon: HQIcon) -> Path {
        switch icon {
        case .settings:
            var path = Path()
            path.move(to: CGPoint(x: 9.671, y: 4.136))
            path.addCurve(to: CGPoint(x: 12.000499999999997, y: 2.0174266244154078), control1: CGPoint(x: 9.785173812182183, y: 2.9348441038624573), control2: CGPoint(x: 10.793930007743352, y: 2.017426624415408))
            path.addCurve(to: CGPoint(x: 14.329999999999998, y: 4.136000000000001), control1: CGPoint(x: 13.207069992256644, y: 2.0174266244154073), control2: CGPoint(x: 14.215826187817813, y: 2.9348441038624555))
            path.addCurve(to: CGPoint(x: 15.491463246470037, y: 5.956677015648011), control1: CGPoint(x: 14.397209653307376, y: 4.895940957172396), control2: CGPoint(x: 14.830660599914529, y: 5.575406431690855))
            path.addCurve(to: CGPoint(x: 17.648999999999997, y: 6.051000000000001), control1: CGPoint(x: 16.152265893025547, y: 6.337947599605167), control2: CGPoint(x: 16.957445351781157, y: 6.373148357768147))
            path.addCurve(to: CGPoint(x: 20.642516591413326, y: 7.011104349617394), control1: CGPoint(x: 18.745247566760284, y: 5.553292414485671), control2: CGPoint(x: 20.040246823159162, y: 5.968634832291626))
            path.addCurve(to: CGPoint(x: 19.979000000000003, y: 10.084), control1: CGPoint(x: 21.244786359667494, y: 8.053573866943163), control2: CGPoint(x: 20.95774820028221, y: 9.382912609762036))
            path.addCurve(to: CGPoint(x: 18.983046037157955, y: 11.9995), control1: CGPoint(x: 19.354703100652923, y: 10.522049477200438), control2: CGPoint(x: 18.983046037157955, y: 11.23685069461124))
            path.addCurve(to: CGPoint(x: 19.979, y: 13.915), control1: CGPoint(x: 18.983046037157955, y: 12.762149305388757), control2: CGPoint(x: 19.35470310065292, y: 13.47695052279956))
            path.addCurve(to: CGPoint(x: 20.64251659141333, y: 16.987895650382605), control1: CGPoint(x: 20.95774820028221, y: 14.616087390237961), control2: CGPoint(x: 21.244786359667494, y: 15.945426133056836))
            path.addCurve(to: CGPoint(x: 17.649, y: 17.948), control1: CGPoint(x: 20.040246823159166, y: 18.030365167708375), control2: CGPoint(x: 18.745247566760284, y: 18.44570758551433))
            path.addCurve(to: CGPoint(x: 15.49146324647004, y: 18.042322984351987), control1: CGPoint(x: 16.957445351781164, y: 17.62585164223185), control2: CGPoint(x: 16.15226589302555, y: 17.661052400394833))
            path.addCurve(to: CGPoint(x: 14.330000000000002, y: 19.863), control1: CGPoint(x: 14.830660599914532, y: 18.423593568309144), control2: CGPoint(x: 14.39720965330738, y: 19.103059042827603))
            path.addCurve(to: CGPoint(x: 12.000500000000002, y: 21.981573375584592), control1: CGPoint(x: 14.215826187817818, y: 21.064155896137542), control2: CGPoint(x: 13.207069992256649, y: 21.981573375584592))
            path.addCurve(to: CGPoint(x: 9.671000000000003, y: 19.863), control1: CGPoint(x: 10.793930007743358, y: 21.981573375584592), control2: CGPoint(x: 9.785173812182189, y: 21.064155896137542))
            path.addCurve(to: CGPoint(x: 8.509232909611878, y: 18.041722840777325), control1: CGPoint(x: 9.60391286937964, y: 19.102780624453864), control2: CGPoint(x: 9.170316164404799, y: 18.423040441056976))
            path.addCurve(to: CGPoint(x: 6.3510000000000035, y: 17.948), control1: CGPoint(x: 7.8481496548189575, y: 17.660405240497674), control2: CGPoint(x: 7.042650268652546, y: 17.625425841203143))
            path.addCurve(to: CGPoint(x: 3.3574834085866687, y: 16.98789565038261), control1: CGPoint(x: 5.25475243323972, y: 18.445707585514338), control2: CGPoint(x: 3.9597531768408345, y: 18.030365167708382))
            path.addCurve(to: CGPoint(x: 4.021000000000004, y: 13.914999999999997), control1: CGPoint(x: 2.755213640332503, y: 15.945426133056838), control2: CGPoint(x: 3.042251799717787, y: 14.61608739023796))
            path.addCurve(to: CGPoint(x: 5.016953962842048, y: 11.999499999999996), control1: CGPoint(x: 4.645296899347083, y: 13.476950522799557), control2: CGPoint(x: 5.016953962842049, y: 12.762149305388755))
            path.addCurve(to: CGPoint(x: 4.021000000000003, y: 10.083999999999998), control1: CGPoint(x: 5.016953962842047, y: 11.236850694611238), control2: CGPoint(x: 4.645296899347081, y: 10.522049477200436))
            path.addCurve(to: CGPoint(x: 3.3589842355083293, y: 7.012713187329257), control1: CGPoint(x: 3.0436788918810223, y: 9.382597709635709), control2: CGPoint(x: 2.757396530935995, y: 8.054449216758293))
            path.addCurve(to: CGPoint(x: 6.35, y: 6.051), control1: CGPoint(x: 3.960571940080663, y: 5.97097715790022), control2: CGPoint(x: 5.254007988903394, y: 5.555093524023328))
            path.addCurve(to: CGPoint(x: 8.507536753529962, y: 5.956677015648013), control1: CGPoint(x: 7.041554648218838, y: 6.373148357768148), control2: CGPoint(x: 7.846734106974452, y: 6.337947599605169))
            path.addCurve(to: CGPoint(x: 9.669, y: 4.136000000000001), control1: CGPoint(x: 9.16833940008547, y: 5.5754064316908565), control2: CGPoint(x: 9.601790346692622, y: 4.895940957172397))
            path.move(to: CGPoint(x: 9.0, y: 12.0))
            path.addCurve(to: CGPoint(x: 12.0, y: 15.0), control1: CGPoint(x: 9.0, y: 13.65685424949238), control2: CGPoint(x: 10.343145750507619, y: 15.0))
            path.addCurve(to: CGPoint(x: 15.0, y: 12.0), control1: CGPoint(x: 13.65685424949238, y: 15.0), control2: CGPoint(x: 15.0, y: 13.656854249492381))
            path.addCurve(to: CGPoint(x: 12.0, y: 9.0), control1: CGPoint(x: 15.0, y: 10.34314575050762), control2: CGPoint(x: 13.65685424949238, y: 9.0))
            path.addCurve(to: CGPoint(x: 9.0, y: 12.0), control1: CGPoint(x: 10.34314575050762, y: 9.0), control2: CGPoint(x: 9.0, y: 10.34314575050762))
            return path
        case .chevronRight:
            var path = Path()
            path.move(to: CGPoint(x: 9.0, y: 18.0))
            path.addLine(to: CGPoint(x: 15.0, y: 12.0))
            path.addLine(to: CGPoint(x: 9.0, y: 6.0))
            return path
        case .close:
            var path = Path()
            path.move(to: CGPoint(x: 18.0, y: 6.0))
            path.addLine(to: CGPoint(x: 6.0, y: 18.0))
            path.move(to: CGPoint(x: 6.0, y: 6.0))
            path.addLine(to: CGPoint(x: 18.0, y: 18.0))
            return path
        case .undo:
            var path = Path()
            path.move(to: CGPoint(x: 9.0, y: 14.0))
            path.addLine(to: CGPoint(x: 4.0, y: 9.0))
            path.addLine(to: CGPoint(x: 9.0, y: 4.0))
            path.move(to: CGPoint(x: 4.0, y: 9.0))
            path.addLine(to: CGPoint(x: 14.5, y: 9.0))
            path.addCurve(to: CGPoint(x: 20.0, y: 14.5), control1: CGPoint(x: 17.537566124069365, y: 9.0), control2: CGPoint(x: 20.0, y: 11.462433875930635))
            path.addCurve(to: CGPoint(x: 14.5, y: 20.0), control1: CGPoint(x: 20.0, y: 17.537566124069365), control2: CGPoint(x: 17.537566124069365, y: 20.0))
            path.addLine(to: CGPoint(x: 11.0, y: 20.0))
            return path
        case .redo:
            var path = Path()
            path.move(to: CGPoint(x: 15.0, y: 14.0))
            path.addLine(to: CGPoint(x: 20.0, y: 9.0))
            path.addLine(to: CGPoint(x: 15.0, y: 4.0))
            path.move(to: CGPoint(x: 20.0, y: 9.0))
            path.addLine(to: CGPoint(x: 9.5, y: 9.0))
            path.addCurve(to: CGPoint(x: 4.0, y: 14.5), control1: CGPoint(x: 6.462433875930637, y: 9.0), control2: CGPoint(x: 4.000000000000001, y: 11.462433875930635))
            path.addCurve(to: CGPoint(x: 9.499999999999998, y: 20.0), control1: CGPoint(x: 4.0, y: 17.537566124069365), control2: CGPoint(x: 6.462433875930635, y: 20.0))
            path.addLine(to: CGPoint(x: 13.0, y: 20.0))
            return path
        case .pen:
            var path = Path()
            path.move(to: CGPoint(x: 21.174, y: 6.812))
            path.addCurve(to: CGPoint(x: 21.174499973925293, y: 2.8255000257191907), control1: CGPoint(x: 22.274979624440473, y: 5.711296489326919), control2: CGPoint(x: 22.27520347039047, y: 3.926479664364005))
            path.addCurve(to: CGPoint(x: 17.187999999650938, y: 2.825000000348974), control1: CGPoint(x: 20.073796477460117, y: 1.7245203870743762), control2: CGPoint(x: 18.288979652500092, y: 1.7242965180917027))
            path.addLine(to: CGPoint(x: 3.842, y: 16.174))
            path.addCurve(to: CGPoint(x: 3.3419999999999996, y: 17.004), control1: CGPoint(x: 3.609819385504982, y: 16.405500211407475), control2: CGPoint(x: 3.4381136476369565, y: 16.690531736268394))
            path.addLine(to: CGPoint(x: 2.021, y: 21.355999999999998))
            path.addCurve(to: CGPoint(x: 2.1467962023669966, y: 21.853002356793183), control1: CGPoint(x: 1.9683453782191922, y: 21.532195262874353), control2: CGPoint(x: 2.0166585737449263, y: 21.72307361682059))
            path.addCurve(to: CGPoint(x: 2.644, y: 21.977999999999998), control1: CGPoint(x: 2.276933830989067, y: 21.982931096765782), control2: CGPoint(x: 2.467889550153789, y: 22.030937598256887))
            path.addLine(to: CGPoint(x: 6.997, y: 20.657999999999998))
            path.addCurve(to: CGPoint(x: 7.826999999999999, y: 20.160999999999998), control1: CGPoint(x: 7.310169162042503, y: 20.56275124021195), control2: CGPoint(x: 7.595173224122793, y: 20.392092181351824))
            path.closeSubpath()
            return path
        case .pencil:
            var path = Path()
            path.move(to: CGPoint(x: 21.174, y: 6.812))
            path.addCurve(to: CGPoint(x: 21.174499973925293, y: 2.8255000257191907), control1: CGPoint(x: 22.274979624440473, y: 5.711296489326919), control2: CGPoint(x: 22.27520347039047, y: 3.926479664364005))
            path.addCurve(to: CGPoint(x: 17.187999999650938, y: 2.825000000348974), control1: CGPoint(x: 20.073796477460117, y: 1.7245203870743762), control2: CGPoint(x: 18.288979652500092, y: 1.7242965180917027))
            path.addLine(to: CGPoint(x: 3.842, y: 16.174))
            path.addCurve(to: CGPoint(x: 3.3419999999999996, y: 17.004), control1: CGPoint(x: 3.609819385504982, y: 16.405500211407475), control2: CGPoint(x: 3.4381136476369565, y: 16.690531736268394))
            path.addLine(to: CGPoint(x: 2.021, y: 21.355999999999998))
            path.addCurve(to: CGPoint(x: 2.1467962023669966, y: 21.853002356793183), control1: CGPoint(x: 1.9683453782191922, y: 21.532195262874353), control2: CGPoint(x: 2.0166585737449263, y: 21.72307361682059))
            path.addCurve(to: CGPoint(x: 2.644, y: 21.977999999999998), control1: CGPoint(x: 2.276933830989067, y: 21.982931096765782), control2: CGPoint(x: 2.467889550153789, y: 22.030937598256887))
            path.addLine(to: CGPoint(x: 6.997, y: 20.657999999999998))
            path.addCurve(to: CGPoint(x: 7.826999999999999, y: 20.160999999999998), control1: CGPoint(x: 7.310169162042503, y: 20.56275124021195), control2: CGPoint(x: 7.595173224122793, y: 20.392092181351824))
            path.closeSubpath()
            path.move(to: CGPoint(x: 15.0, y: 5.0))
            path.addLine(to: CGPoint(x: 19.0, y: 9.0))
            return path
        case .clear:
            var path = Path()
            path.move(to: CGPoint(x: 21.0, y: 21.0))
            path.addLine(to: CGPoint(x: 8.0, y: 21.0))
            path.addCurve(to: CGPoint(x: 6.58, y: 20.413), control1: CGPoint(x: 7.467387895652714, y: 21.001216677346953), control2: CGPoint(x: 6.956290043855496, y: 20.789938903399793))
            path.addLine(to: CGPoint(x: 2.586, y: 16.414))
            path.addCurve(to: CGPoint(x: 2.5860000000000003, y: 13.586000000000002), control1: CGPoint(x: 1.8052361233342746, y: 15.633000297028373), control2: CGPoint(x: 1.8052361233342746, y: 14.36699970297163))
            path.addLine(to: CGPoint(x: 12.586, y: 3.586000000000002))
            path.addCurve(to: CGPoint(x: 14.0005, y: 2.999927066718792), control1: CGPoint(x: 12.961096021420602, y: 3.2107519870096937), control2: CGPoint(x: 13.469926634160045, y: 2.999927066718792))
            path.addCurve(to: CGPoint(x: 15.415, y: 3.586000000000002), control1: CGPoint(x: 14.531073365839957, y: 2.999927066718792), control2: CGPoint(x: 15.039903978579398, y: 3.2107519870096928))
            path.addLine(to: CGPoint(x: 21.414, y: 9.586000000000002))
            path.addCurve(to: CGPoint(x: 21.414, y: 12.414000000000001), control1: CGPoint(x: 22.19476387666573, y: 10.36699970297163), control2: CGPoint(x: 22.19476387666573, y: 11.633000297028374))
            path.addLine(to: CGPoint(x: 12.834, y: 21.0))
            path.move(to: CGPoint(x: 5.082, y: 11.09))
            path.addLine(to: CGPoint(x: 13.91, y: 19.918))
            return path
        case .grid:
            var path = Path()
            path.move(to: CGPoint(x: 3.0, y: 9.0))
            path.addLine(to: CGPoint(x: 21.0, y: 9.0))
            path.move(to: CGPoint(x: 3.0, y: 15.0))
            path.addLine(to: CGPoint(x: 21.0, y: 15.0))
            path.move(to: CGPoint(x: 9.0, y: 3.0))
            path.addLine(to: CGPoint(x: 9.0, y: 21.0))
            path.move(to: CGPoint(x: 15.0, y: 3.0))
            path.addLine(to: CGPoint(x: 15.0, y: 21.0))
            path.move(to: CGPoint(x: 5.0, y: 3.0))
            path.addLine(to: CGPoint(x: 19.0, y: 3.0))
            path.addCurve(to: CGPoint(x: 21.0, y: 5.0), control1: CGPoint(x: 20.104569499661586, y: 3.0), control2: CGPoint(x: 21.0, y: 3.895430500338413))
            path.addLine(to: CGPoint(x: 21.0, y: 19.0))
            path.addCurve(to: CGPoint(x: 19.0, y: 21.0), control1: CGPoint(x: 21.0, y: 20.104569499661586), control2: CGPoint(x: 20.104569499661586, y: 21.0))
            path.addLine(to: CGPoint(x: 5.0, y: 21.0))
            path.addCurve(to: CGPoint(x: 3.0, y: 19.0), control1: CGPoint(x: 3.8954305003384135, y: 21.0), control2: CGPoint(x: 3.0, y: 20.104569499661586))
            path.addLine(to: CGPoint(x: 3.0, y: 5.0))
            path.addCurve(to: CGPoint(x: 5.0, y: 3.0), control1: CGPoint(x: 3.0, y: 3.8954305003384126), control2: CGPoint(x: 3.8954305003384135, y: 3.0))
            path.closeSubpath()
            return path
        }
    }
}
