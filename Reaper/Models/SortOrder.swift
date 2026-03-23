enum SortOrder: String, CaseIterable, Identifiable {
    case cpu = "CPU"
    case memory = "Memory"
    case name = "Name"

    var id: String { rawValue }
}
