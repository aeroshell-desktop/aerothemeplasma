#include <KConfig>
#include <KConfigGroup>

int main()
{
    KConfig globals("kdeglobals");
    KConfigGroup general(&globals, "General");
    if (general.readEntry(QStringLiteral("ColorScheme")) != QStringLiteral("Breeze")) {
        return 0;
    }
    general.writeEntry(QStringLiteral("ColorScheme"), QStringLiteral("BreezeClassic"));
    // No need to migrate the serialized colors because they're the same
}
