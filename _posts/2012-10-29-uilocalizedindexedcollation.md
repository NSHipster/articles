---
layout: post
title: UILocalizedIndexedCollation

ref: "http://developer.apple.com/library/ios/#documentation/iPhone/Reference/UILocalizedIndexedCollation_Class/UILocalizedIndexedCollation.html"
framework: UIKit
rating: 7.1
published: true
description: UITableView starts to become unwieldy once it gets to few hundred rows. If users are reduced to frantically scratching at the screen like a cat playing Fruit Ninja in order to get at what they want… you may want to rethink your UI approach.
---

UITableView starts to become unwieldy once it gets to few hundred rows. If users are reduced to frantically scratching at the screen like a [cat playing Fruit Ninja](http://www.youtube.com/watch?v=CdEBgZ5Y46U) in order to get at what they want... you may want to rethink your UI approach.

So, what are your options?

Well, you could organize your data into a hierarchy, which could dramatically reduce the number of rows displayed on each screen in fashion, based on its [branching factor](http://en.wikipedia.org/wiki/Branching_factor).

You could also add a `UISearchBar` to the top of your table view, allowing the user to filter on keywords to get exactly what they're looking for (or--perhaps more importantly--determine that what they seek doesn't exist in the first place).

There is also a third approach, which is generally under-utilized in iOS applications: **section index titles**. These are the vertically flowing letters found along the right side of table views in your Address Book contacts list or Music library:

![Section Index Titles Example](http://nshipster.s3.amazonaws.com/uilocalizedindexedcollation-example.png)

As the user scrolls their finger down the list, the table view jumps to the corresponding section. Even the most tiresome table view is rendered significantly more usable as a result.

Section index titles can be enabled by implementing the following `UITableViewDataSource` delegate methods:

- `-sectionIndexTitlesForTableView:` - Returns an array of the section index titles to be displayed along the right hand side of the table view, such as the alphabetical list "A...Z" + "#". Section index titles are short--generally limited to 2 Unicode characters.

- `-tableView:sectionForSectionIndexTitle:atIndex:` - Returns the section index that the table view should jump to when the user touches a particular section index title.

As longtime readers of NSHipster doubtless have already guessed, the process of generating that alphabetical list is not something you would want to have to generate yourself. What it means to something to be alphabetically sorted, or even what is meant by an "alphabet" varies wildly across different locales.

Coming to our rescue is `UILocalizedIndexedCollation`.

---

`UILocalizedIndexCollation` is a class that helps to organize data in table views with section index titles in a locale-aware manner. Rather than creating the object directly, a shared instance corresponding to the current locale supported by your application is accessed, with `UILocalizedIndexCollation +currentCollation`

The first task for `UILocalizedIndexCollation` is to determine what section index titles to display for the current locale, which are can be read from the `sectionIndexTitles` property.

To give you a better idea of how section index titles vary between locales:

> In order to see these for yourself, you'll need to explicitly add the desired locales to your Project Localizations list.

<table>
  <thead>
    <tr>
      <th>Locale</th>
      <th>Section Index Titles</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>en_US</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, #</tt></td>
    </tr>
    <tr>
      <td>ja_JP</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, あ, か, さ, た, な, は, ま, や, ら, わ, #</tt></td>
    </tr>
    <tr>
      <td>sv_SE</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, Å, Ä, Ö, #</tt></td>
    </tr>
    <tr>
      <td>ko_KO</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, ㄱ, ㄴ, ㄷ, ㄹ, ㅁ, ㅂ, ㅅ, ㅇ, ㅈ, ㅊ, ㅋ, ㅌ, ㅍ, ㅎ, #</tt></td>
    </tr>
    <tr>
      <td>ar_SA</td>
      <td><tt>A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z, آ, ب, ت, ث, ج, ح, خ, د, ذ, ر, ز, س, ش, ص, ض, ط, ظ, ع, غ, ف, ق, ك, ل, م, ن, ه, و, ي, #</tt></td>
    </tr>
  </tbody>
</table>

Aren't you glad you don't have to do this yourself?

So with the list of section titles laid out before you, the next step is to determine what section each object should be assigned to. This is accomplished with `-sectionForObject:collationStringSelector:`. This method returns the `NSInteger` index corresponding to the string value of the object when performing the specified selector. This selector might be something like `localizedName`, `title`, or even just `description`.

So, as it stands, your table view data source has a NSArray property corresponding to the number of sections in the table view, with each element of the array containing an array representing each row in the section. Since collation was handled by `UILocalizedIndexedCollation`, it makes sense for it to sort the rows in each section as well. `– sortedArrayFromArray:collationStringSelector:` does this in similar fashion to `-sectionForObject:collationStringSelector:`, by sorting the objects in the section by their respective localized title.

Finally, the table view should implement `-tableView:sectionForSectionIndexTitle:atIndex:`, so that touching a section index title jumps to the corresponding section in the table view. `UILocalizedIndexedCollation -sectionForSectionIndexTitleAtIndex:` does the trick.

All told, here's what a typical table view data source implementation looks like:

    - (void)setObjects:(NSArray *)objects {
          SEL selector = @selector(localizedTitle)
          NSInteger index, sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
          
          NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
          for (idx = 0; idx < sectionTitlesCount; idx++) {
            [mutableSections addObject:[NSArray array]];
          }
          
          for (id object in objects) {
                NSInteger sectionNumber = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:selector];
            [[mutableSections objectAtIndex:sectionNumber] addObject:object];
          }
          
          for (idx = 0; idx < sectionTitlesCount; idx++) {
            NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
            [mutableSections replaceObjectAtIndex:idx withObject:[collation sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
          }
          
          self.sections = mutableSections;

          [self.tableView reloadData];
    }

    - (NSString *)tableView:(UITableView *)tableView 
    titleForHeaderInSection:(NSInteger)section 
    {
        return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
    }
     
    - (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
        return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    }
     
    - (NSInteger)tableView:(UITableView *)tableView 
    sectionForSectionIndexTitle:(NSString *)title 
                   atIndex:(NSInteger)index 
    {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
    }

## UITableViewIndexSearch

There is one special section index title worth mentioning, and that's `UITableViewIndexSearch`. It's a common pattern to have both a search bar and section indexes. In equal parts convenience and visual consistency, a search icon is often included as the first section index title, which can be touched to bring up the `UISearchBar` in the header of the table view.

To include the search icon in your table view, you would simply prepend the `NSString` constant `UITableViewIndexSearch` to the return value of `-sectionIndexTitlesForTableView:`, and adjust `-tableView:sectionForSectionIndexTitle:atIndex:` to account for the single element shift.

---

So remember, NSHipsters one and all: if you see an excessively long table view, kill it with fire!

...which is to say, refactor your content with some combination of hierarchies, a search bar, and section indexes. And when implementing section index titles, take advantage of `UILocalizedIndexCollation`.

Together, we can put an end to scroll view-induced repetitive stress injuries, and spend more time enjoying the finer things in life, like watching videos of pets playing with iPads.

