function rootObject() {
    var next = parent
    while (next && next.parent)
        next = next.parent
    return next
}

function findParent(child, propertyName) {
    if (!child)
        return null
    var next = child.parent
    while (next && !next.hasOwnProperty(propertyName))
        next = next.parent
    return next
}
