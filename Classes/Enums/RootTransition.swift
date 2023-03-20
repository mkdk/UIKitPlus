public enum RootTransition {
	case setRoot(IPresentable, String, RootTransitionAnimation)
	case setTab(Int)
	case push(IPresentable)
	case pop
	case popToRoot
	case present(IPresentable)
	case dismiss
	case dismissOnRoot
}
