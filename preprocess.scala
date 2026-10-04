import scala.io.Source
import java.io.{File, PrintWriter}

@main def main =
  val allAttendees = loadAttendees("./raw_names")
  println(s"Number of attendees (with duplicates): ${allAttendees.length}")
  println("First attendees:")
  allAttendees.take(5).foreach(println)
  val uniqueAttendees = allAttendees.toSet.toList.sortBy(_.email)
  println(s"Number of unique attendees: ${uniqueAttendees.length}")
  uniqueAttendees.take(5).foreach(println)

  val attendeesByEmail = getAttendeesByEmail(uniqueAttendees)
  val nonUniqueEmailAddresses = attendeesByEmail.filter(_._2.length >= 2)
  println(s"Duplicated email addresses (${nonUniqueEmailAddresses.size}):")
  printMap(nonUniqueEmailAddresses)

  val mergedAttendees = mergeEntries(attendeesByEmail)
  val nonUniqueEmailAddressesAfterMerge =
    mergedAttendees.filter(_._2.length >= 2)
  println(
    s"Duplicated email addresses after merge (${nonUniqueEmailAddressesAfterMerge.size}):"
  )
  printMap(nonUniqueEmailAddressesAfterMerge)

  val filteredAttendees =
    mergedAttendees.values.flatten.toList
      .sortBy(_.name.map(_.toLower))
  println(
    s"Filtered attendees: ${filteredAttendees.size}\n${filteredAttendees.take(5).toList}"
  )

  val possibleDuplicates = findPossibleDuplicates(filteredAttendees)
  println(s"Possible duplicates:\n${possibleDuplicates.mkString("\n")}\n")

  val finalAttendees = filteredAttendees
    .filterNot(possibleDuplicates.contains)
    .map(_.splitOrganizations)
  println(s"Final number of attendees: ${finalAttendees.size}")

  // Check for remaining invalid characters
  finalAttendees.forall(_.isCvsExportable)
  writeCsv("./final_attendees.csv", finalAttendees)

def loadAttendees(path: String): List[Attendee] =
  val data = Source.fromFile(path).getLines
  data
    .drop(1) // Drop header
    .filterNot(_.isEmpty)
    .map(Attendee.parseLine)
    .toList

def getAttendeesByEmail(
    attendees: List[Attendee]
): Map[String, List[Attendee]] =
  attendees.foldLeft(Map[String, List[Attendee]]())((map, attendee) =>
    val email = attendee.email
    map + (email -> (if map.contains(email) then attendee :: map(email)
                     else List(attendee)))
  )

def mergeEntries(
    entries: Map[String, List[Attendee]]
): Map[String, List[Attendee]] =
  def allSame[A](attendees: List[Attendee])(extractor: Attendee => A) =
    attendees match
      case head :: tail =>
        val compareObject = extractor(head)
        tail.map(extractor).forall(_ == compareObject)
      case Nil => true

  def tryMerge(attendees: List[Attendee])(
      extractor: Attendee => String
  ): List[Attendee] =
    def helper(candidates: List[Attendee]): List[Attendee] =
      candidates match
        case head :: tail =>
          val comparisonValue = extractor(head)
          if attendees
              .map(extractor)
              .forall(value =>
                comparisonValue.contains(value) || isPartiallyLowercase(
                  value,
                  comparisonValue
                )
              )
          then {
            println(s"Found merge with value: '${comparisonValue}'")
            List(head)
          } else helper(tail)
        case Nil => attendees // No merge found
    if attendees.size > 1 then helper(attendees)
    else attendees

  def mergeOrganizations(
      email: String,
      duplicates: List[Attendee]
  ): (String, List[Attendee]) =
    assert(duplicates.size > 0, "No attendee with email address '${email}'")
    val merged =
      if allSame(duplicates)(_.name) then tryMerge(duplicates)(_.organization)
      else duplicates
    email -> merged

  def mergeNames(
      email: String,
      duplicates: List[Attendee]
  ): (String, List[Attendee]) =
    val merged =
      if allSame(duplicates)(_.organization) then tryMerge(duplicates)(_.name)
      else duplicates
    email -> merged

  entries.map(mergeOrganizations).map(mergeNames)

def findPossibleDuplicates(attendees: List[Attendee]): List[Attendee] =
  def isPossibleDuplicate(a: Attendee, b: Attendee): Boolean =
    def isPossibleDuplicatedFields(candidate: String, value: String): Boolean =
      candidate == value || isPartiallyLowercase(candidate, value)
    isPossibleDuplicatedFields(a.name, b.name) && (
      isPossibleDuplicatedFields(
        a.organization,
        b.organization
      ) || (b.organization.contains(a.organization))
    )
  attendees
    .combinations(2)
    .map(
      _ match
        case a :: b :: Nil =>
          if isPossibleDuplicate(a, b) then {
            println(s"\nPossible duplicates: ${a} < ${b}\n")
            Some(a)
          } else if isPossibleDuplicate(b, a) then {
            println(s"\nPossible duplicates: ${b} < ${a}\n")
            Some(b)
          } else None
        case _ => // Should never occur
          ???
    )
    .flatten
    .toList

def isPartiallyLowercase(candidate: String, value: String): Boolean =
  val valueLower = value.map(_.toLower)
  if candidate == valueLower then { true }
  else {
    val candidateFields = candidate.split(" ")
    val valueFields = value.split(" ")
    val valueLowerFields = valueLower.split(" ")
    if candidateFields.size == valueFields.size then
      candidateFields
        .lazyZip(valueFields)
        .lazyZip(valueLowerFields)
        .forall((c, a, b) => c == a || c == b)
    else false
  }

def writeCsv(path: String, attendees: List[Attendee]): Unit =
  val writer = PrintWriter(File(path))
  writer.write("Name,Organization\n")
  writer.write(attendees.map(_.toCsv).mkString("\n"))
  writer.close

def printMap(map: Map[String, List[Attendee]]): Unit =
  map
    .map((email, attendees) => s"${email}:\n${attendees.mkString("\n")}\n")
    .foreach(println)

case class Attendee(name: String, organization: String, email: String):
  def splitOrganizations: Attendee =
    copy(organization = organization.map(c => if c != ',' then c else '/'))

  def isCvsExportable: Boolean =
    !name.contains(',') && !organization.contains(',')

  def toCsv: String = s"${name},${organization}"

object Attendee:
  def parseLine(line: String): Attendee =
    val markedLine = line + "\t!" // Trailing tab might be removed otherwise
    val fields = markedLine.split("\t").toList
    assert(fields.lengthIs == 4, s"Line '${line}' does not contain 3 fields")
    Attendee(
      name = fields(1),
      organization = fields(2),
      email = fields(0).map(_.toLower)
    )
